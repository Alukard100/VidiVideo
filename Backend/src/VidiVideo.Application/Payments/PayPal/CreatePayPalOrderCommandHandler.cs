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
        private readonly IUserRepository _userRepository;
        public CreatePayPalOrderCommandHandler(IPayPalService paypal, IPaymentRepository paymentRepository, IUnitOfWork unitOfWork, ICurrentUser currentUser, IPaymentSettings paymentSettings, IUserRepository userRepository)
        {
            _payPal = paypal;
            _paymentRepository = paymentRepository;
            _unitOfWork = unitOfWork;
            _currentUser = currentUser;
            _paymentSettings = paymentSettings;
            _userRepository = userRepository;
        }

        public async Task<PayPalOrderDto> HandleAsync(CreatePayPalOrderCommand command, CancellationToken cancellationToken)
        {
            var subscriberId = _currentUser.UserId ?? throw new UnauthorizedException("User must be logged in");

            if (subscriberId == command.CreatorId) throw new ValidationException("You cannot subscribe to yourself.");

            if (await _paymentRepository.HasActiveSubscriptionAsync(subscriberId, command.CreatorId)) throw new ConflictException("Already subscribed.");

            var creator = await _userRepository.GetByIdAsync(command.CreatorId) ?? throw new NotFoundException("Creator doesn't exist.");

            if (string.IsNullOrWhiteSpace(creator.PayPalMerchantId)) throw new ValidationException("This creator has not connected PayPal");

            var amount = _paymentSettings.SubscriptionPrice;

            var platformFee = _paymentSettings.PlatformFee;

            if (amount <= 0) throw new InvalidOperationException("Subscription price is not configured.");

            if (platformFee < 0 || platformFee >= amount) throw new InvalidOperationException("Platform fee configuration is invalid.");

            var payPalOrder = await _payPal.CreateOrderAsync(amount, platformFee, creator.PayPalMerchantId);

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
