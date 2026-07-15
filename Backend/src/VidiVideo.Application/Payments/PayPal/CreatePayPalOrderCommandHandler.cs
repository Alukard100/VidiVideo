using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;
using VidiVideo.Domain.Entities;

namespace VidiVideo.Application.Payments.PayPal
{
    public sealed class CreatePayPalOrderCommandHandler : ICommandHandler<CreatePayPalOrderCommand, string>
    {
        private readonly IPayPalService _payPal;
        private readonly IPaymentRepository _paymentRepository;
        private readonly IUnitOfWork _unitOfWork;
        private readonly ICurrentUser _currentUser;
        public CreatePayPalOrderCommandHandler(IPayPalService paypal, IPaymentRepository paymentRepository, IUnitOfWork unitOfWork, ICurrentUser currentUser)
        {
            _payPal = paypal;
            _paymentRepository = paymentRepository;
            _unitOfWork = unitOfWork;
            _currentUser = currentUser;
        }

        public async Task<string> HandleAsync(CreatePayPalOrderCommand command, CancellationToken cancellationToken)
        {
            var subscriberId = _currentUser.UserId ?? throw new UnauthorizedException("User must be logged in");
            var subscription = new CreatorSubscription(subscriberId, command.CreatorId);

            await _unitOfWork.BeginAsync();

            try
            {
                if (await _paymentRepository.HasActiveSubscriptionAsync(subscriberId, command.CreatorId))
                    throw new ConflictException("Already subscribed.");

                await _paymentRepository.CreateSubscriptionAsync(subscription);

                string paymentId = await _payPal.CreateOrderAsync(command.Amount);

                var payment = new Payment(subscription.Id, command.Amount, paymentId);

                await _paymentRepository.CreatePaymentAsync(payment);

                await _unitOfWork.CommitAsync(cancellationToken);

                return paymentId;
            }
            catch (ConflictException ex)
            {
                await _unitOfWork.RollbackAsync();
                Console.WriteLine(ex.Message);
                return "Failed";
            }
            catch (Exception ex)
            {
                await _unitOfWork.RollbackAsync();
                Console.WriteLine(ex.ToString());
                return "Failed";
            }



        }
    }
}
