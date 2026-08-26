using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;
using VidiVideo.Domain.Enums;

namespace VidiVideo.Application.Payments.Refunds;

public sealed class ApproveRefundRequestCommandHandler
    : ICommandHandler<ApproveRefundRequestCommand, bool>
{
    private readonly IRefundRequestRepository _refundRepository;
    private readonly IPayPalService _payPalService;
    private readonly ICurrentUser _currentUser;
    private readonly IUnitOfWork _unitOfWork;
    private readonly IPaymentSettings _paymentSettings;

    public ApproveRefundRequestCommandHandler(
        IRefundRequestRepository refundRepository,
        IPayPalService payPalService,
        ICurrentUser currentUser,
        IUnitOfWork unitOfWork,
        IPaymentSettings paymentSettings)
    {
        _refundRepository = refundRepository;
        _payPalService = payPalService;
        _currentUser = currentUser;
        _unitOfWork = unitOfWork;
        _paymentSettings = paymentSettings;
    }

    public async Task<bool> HandleAsync(
        ApproveRefundRequestCommand command,
        CancellationToken cancellationToken)
    {
        var reviewerId = _currentUser.UserId
            ?? throw new UnauthorizedException(
                "Must be logged in.");

        var request =
            await _refundRepository.GetByIdAsync(
                command.RefundRequestId,
                cancellationToken)
            ?? throw new NotFoundException(
                "Refund request doesn't exist.");

        if (request.Status != RefundRequestStatus.Pending)
            throw new ValidationException(
                "Refund request has already been reviewed.");

        var payment = request.Payment;

        if (payment.Status != PaymentStatus.Completed)
            throw new ValidationException(
                "Payment is not eligible for refund.");

        if (string.IsNullOrWhiteSpace(
            payment.ProviderCaptureId))
        {
            throw new ValidationException(
                "Payment capture ID is missing.");
        }

        var creator = payment.Subscription.Creator;
        if (creator == null || string.IsNullOrWhiteSpace(creator.PayPalMerchantId)) throw new ValidationException("Creator PayPal account is not connected.");

        var refund =
            await _payPalService.RefundAsync(
                payment.ProviderCaptureId,
                payment.Amount,
                payment.Currency,
                creator.PayPalMerchantId);

        if (!refund.Status.Equals(
            "COMPLETED",
            StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException(
                "PayPal refund was not completed.");
        }

        payment.MarkRefunded(
            refund.RefundId);

        payment.Subscription.Deactivate();

        request.Approve(
            reviewerId);

        await _unitOfWork.SaveChangesAsync(
            cancellationToken);

        return true;
    }
}