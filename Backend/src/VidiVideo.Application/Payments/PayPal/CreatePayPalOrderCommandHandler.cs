using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;
using VidiVideo.Domain.Entities;

namespace VidiVideo.Application.Payments.PayPal
{
    public sealed class CreatePayPalOrderCommandHandler : ICommandHandler<CreatePayPalOrderCommand, PayPalOrderDto>
    {
        private readonly IPayPalService _payPal;
        private readonly IPaymentRepository _paymentRepository;
        private readonly IUnitOfWork _unitOfWork;
        private readonly ICurrentUser _currentUser;
        private readonly IPaymentSettings _paymentSettings;
        public CreatePayPalOrderCommandHandler(IPayPalService paypal, IPaymentRepository paymentRepository, IUnitOfWork unitOfWork, ICurrentUser currentUser, IPaymentSettings paymentSettings)
        {
            _payPal = paypal;
            _paymentRepository = paymentRepository;
            _unitOfWork = unitOfWork;
            _currentUser = currentUser;
            _paymentSettings = paymentSettings;
        }

        public async Task<PayPalOrderDto> HandleAsync(CreatePayPalOrderCommand command, CancellationToken cancellationToken)
        {
            var subscriberId = _currentUser.UserId ?? throw new UnauthorizedException("User must be logged in");

            if (subscriberId == command.CreatorId) throw new ValidationException("You cannot subscribe to yourself.");

            if (await _paymentRepository.HasActiveSubscriptionAsync(subscriberId, command.CreatorId)) throw new ConflictException("Already subscribed.");

            var amount = _paymentSettings.SubscriptionPrice;

            if (amount <= 0) throw new InvalidOperationException("Subscription price is not configured.");

            var payPalOrder = await _payPal.CreateOrderAsync(amount);

            await _unitOfWork.BeginAsync(cancellationToken);

            try
            {
                var subscription = new CreatorSubscription(subscriberId, command.CreatorId);

                var payment = new Payment(subscription.Id, amount, payPalOrder.OrderId);

                await _paymentRepository.CreateSubscriptionAsync(subscription);

                await _paymentRepository.CreatePaymentAsync(payment);

                await _unitOfWork.CommitAsync(cancellationToken);

                return payPalOrder;
            }
            catch
            {
                await _unitOfWork.RollbackAsync(cancellationToken);
                throw;
            }
        }
    }
}
