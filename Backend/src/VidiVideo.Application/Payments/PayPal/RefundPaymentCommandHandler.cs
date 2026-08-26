using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;

namespace VidiVideo.Application.Payments.PayPal;

public sealed class RefundPaymentCommandHandler : ICommandHandler<RefundPaymentCommand, bool>
{
    private readonly IPaymentRepository _paymentRepository;
    private readonly IPayPalService _payPalService;
    private readonly IUnitOfWork _unitOfWork;
    private readonly IPaymentSettings _paymentSettings;
    public RefundPaymentCommandHandler(IPaymentRepository paymentRepository, IPayPalService payPalService, IUnitOfWork unitOfWork, IPaymentSettings paymentSettings)
    {
        _paymentRepository = paymentRepository;
        _payPalService = payPalService;
        _unitOfWork = unitOfWork;
        _paymentSettings = paymentSettings;
    }
    public async Task<bool> HandleAsync(RefundPaymentCommand command, CancellationToken cancellationToken)
    {
        var payment = await _paymentRepository.GetPaymentByIdAsync(command.PaymentId, cancellationToken) ?? throw new NotFoundException("Payment doesn't exist");

        var subscription = await _paymentRepository.GetSubscriptionByIdAsync(payment.SubscriptionId) ?? throw new NotFoundException("Subscription doesn't exist");

        if (string.IsNullOrWhiteSpace(subscription.Creator.PayPalMerchantId)) throw new ValidationException("Creator PayPal account is not connected");

        if (payment.Status != Domain.Enums.PaymentStatus.Completed)
            throw new ValidationException("Only completed payments can be refunded");

        if (string.IsNullOrWhiteSpace(payment.ProviderCaptureId))
            throw new ValidationException("Payment capture ID is missing.");

        var refund = await _payPalService.RefundAsync(payment.ProviderCaptureId, payment.Amount, payment.Currency, subscription.Creator.PayPalMerchantId);

        if (!refund.Status.Equals("COMPLETED", StringComparison.OrdinalIgnoreCase))
            throw new InvalidOperationException("PayPal did not complete the refund");

        payment.MarkRefunded(refund.RefundId);

        if (subscription != null)
            subscription.Deactivate();

        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return true;
    }
}
