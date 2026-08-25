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
    public RefundPaymentCommandHandler(IPaymentRepository paymentRepository, IPayPalService payPalService, IUnitOfWork unitOfWork)
    {
        _paymentRepository = paymentRepository;
        _payPalService = payPalService;
        _unitOfWork = unitOfWork;
    }
    public async Task<bool> HandleAsync(RefundPaymentCommand command, CancellationToken cancellationToken)
    {
        var payment = await _paymentRepository.GetPaymentByIdAsync(command.PaymentId, cancellationToken) ?? throw new NotFoundException("Payment doesn't exist");

        if (payment.Status != Domain.Enums.PaymentStatus.Completed)
            throw new ValidationException("Only completed payments can be refunded");

        if (string.IsNullOrWhiteSpace(payment.ProviderCaptureId))
            throw new ValidationException("Payment capture ID is missing.");

        var refund = await _payPalService.RefundAsync(payment.ProviderCaptureId, payment.Amount, payment.Currency);

        if (!refund.Status.Equals("COMPLETED", StringComparison.OrdinalIgnoreCase))
            throw new InvalidOperationException("PayPal did not complete the refund");

        payment.MarkRefunded(refund.RefundId);

        var subscription = await _paymentRepository.GetSubscriptionByIdAsync(payment.SubscriptionId);

        if (subscription != null)
            subscription.Deactivate();

        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return true;
    }
}
