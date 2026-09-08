using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;

namespace VidiVideo.Application.Payments.PayPal
{
    public sealed class CapturePayPalOrderCommandHandler : ICommandHandler<CapturePayPalOrderCommand, bool>
    {
        private readonly IPayPalService _payPalService;
        private readonly IPaymentRepository _paymentRepository;
        private readonly IUnitOfWork _unitOfWork;
        private readonly ICurrentUser _currentUser;
        public CapturePayPalOrderCommandHandler(IPayPalService payPalService, IPaymentRepository paymentRepository, IUnitOfWork unitOfWork, ICurrentUser currentUser)
        {
            _payPalService = payPalService;
            _paymentRepository = paymentRepository;
            _unitOfWork = unitOfWork;
            _currentUser = currentUser;
        }
        public async Task<bool> HandleAsync(CapturePayPalOrderCommand command, CancellationToken cancellationToken)
        {
            var currentUserId = _currentUser.UserId ?? throw new UnauthorizedException("User must be logged in.");

            var payment = await _paymentRepository.GetPaymentByProviderIdAsync(command.OrderId) ?? throw new NotFoundException("Payment doesn't exist");

            var subscription = payment.Subscription;

            if (subscription is null) throw new NotFoundException("Subscription doesn't exist");

            if (subscription.SubscriberId != currentUserId) throw new ForbiddenException("You cannot capture another user's payment.");

            if (payment.Status == Domain.Enums.PaymentStatus.Completed) return true;

            if (payment.Status == Domain.Enums.PaymentStatus.Refunded) throw new ConflictException("Refunded payments cannot be captured again.");

            if (payment.Status == Domain.Enums.PaymentStatus.Failed) throw new ConflictException("Failed payments cannot be captured again. Start a new payment.");

            if (payment.Status != Domain.Enums.PaymentStatus.Pending) throw new ConflictException($"Payment in status {payment.Status} cannot be captured.");

            PayPalCaptureResult captureOrder;

            try
            {
                captureOrder = await _payPalService.CaptureOrderAsync(command.OrderId);
            }
            catch
            {
                // Pending so caller can retry or verify again
                throw;
            }

            if (!captureOrder.Success || string.IsNullOrWhiteSpace(captureOrder.CaptureId))
            {
                await _unitOfWork.BeginAsync(cancellationToken);

                try
                {
                    payment.MarkFailed();

                    await _unitOfWork.CommitAsync(cancellationToken);
                    return false;
                }
                catch
                {
                    await _unitOfWork.RollbackAsync(cancellationToken);
                    throw;
                }
            }

            await _unitOfWork.BeginAsync(cancellationToken);

            try
            {
                payment.MarkCompleted(captureOrder.CaptureId);
                subscription.Activate();

                await _unitOfWork.CommitAsync(cancellationToken);

                return true;
            }
            catch
            {
                await _unitOfWork.RollbackAsync(cancellationToken);
                throw;
            }

        }
    }
}
