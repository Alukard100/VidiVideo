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
        public CapturePayPalOrderCommandHandler(IPayPalService payPalService, IPaymentRepository paymentRepository, IUnitOfWork unitOfWork)
        {
            _payPalService = payPalService;
            _paymentRepository = paymentRepository;
            _unitOfWork = unitOfWork;
        }
        public async Task<bool> HandleAsync(CapturePayPalOrderCommand command, CancellationToken cancellationToken)
        {

            var payment = await _paymentRepository.GetPaymentByProviderIdAsync(command.OrderId) ?? throw new NotFoundException("Failed");

            var subscription = await _paymentRepository.GetSubscriptionByIdAsync(payment.SubscriptionId);

            await _unitOfWork.BeginAsync(cancellationToken);

            try
            {
                if (subscription == null)
                    throw new NotFoundException("Transaction failed");

                var capturedOrder = await _payPalService.CaptureOrderAsync(command.OrderId);

                if (!capturedOrder.Success ||
                    string.IsNullOrWhiteSpace(
                        capturedOrder.CaptureId))
                {
                    payment.MarkFailed();

                    await _unitOfWork
                        .CommitAsync(cancellationToken);

                    return false;
                }

                payment.MarkCompleted(
                    capturedOrder.CaptureId);

                subscription.Activate();

                await _unitOfWork
                    .CommitAsync(cancellationToken);

                return true;
            }
            catch (Exception)
            {
                payment.MarkFailed();
                await _unitOfWork.CommitAsync(cancellationToken);
                return false;
            }



        }
    }
}
