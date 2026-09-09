using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;
using VidiVideo.Domain.Entities;
using VidiVideo.Domain.Enums;

namespace VidiVideo.Application.Payments.PayPal
{
    public sealed class CapturePayPalOrderCommandHandler : ICommandHandler<CapturePayPalOrderCommand, bool>
    {
        private readonly IPayPalService _payPalService;
        private readonly IPaymentRepository _paymentRepository;
        private readonly IUnitOfWork _unitOfWork;
        private readonly ICurrentUser _currentUser;
        private readonly INotificationRepository _notificationRepository;
        public CapturePayPalOrderCommandHandler(IPayPalService payPalService, IPaymentRepository paymentRepository, IUnitOfWork unitOfWork, ICurrentUser currentUser, INotificationRepository notificationRepository)
        {
            _payPalService = payPalService;
            _paymentRepository = paymentRepository;
            _unitOfWork = unitOfWork;
            _currentUser = currentUser;
            _notificationRepository = notificationRepository;
        }
        public async Task<bool> HandleAsync(CapturePayPalOrderCommand command, CancellationToken cancellationToken)
        {
            if (string.IsNullOrWhiteSpace(command.OrderId))
                throw new ValidationException("Order ID is required.");

            var orderId = command.OrderId.Trim();

            if (orderId.Length > 256)
                throw new ValidationException("Order ID cannot exceed 256 characters.");

            var currentUserId = _currentUser.UserId ?? throw new UnauthorizedException("User must be logged in.");

            var payment = await _paymentRepository.GetPaymentByProviderIdAsync(orderId) ?? throw new NotFoundException("Payment doesn't exist");

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
                captureOrder = await _payPalService.CaptureOrderAsync(orderId);
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

                var notification = new Notification(
                    subscription.SubscriberId,
                    "Subscription activated",
                    "Your payment was successful and your subscription is now active.",
                    NotificationType.Subscription);

                var creatorNotification = new Notification(
                    subscription.CreatorId,
                    "New subscriber",
                    "A user has successfully subscribed to your channel.",
                    NotificationType.Subscription);

                await _notificationRepository.CreateAsync(notification);
                await _notificationRepository.CreateAsync(creatorNotification);

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
