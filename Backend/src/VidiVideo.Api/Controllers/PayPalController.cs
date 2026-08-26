using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VidiVideo.Application.Common;
using VidiVideo.Application.Payments.PayPal;

namespace VidiVideo.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PayPalController : ControllerBase
    {
        private readonly ICommandHandler<CreatePayPalOrderCommand, PayPalOrderDto> _createHandler;
        private readonly ICommandHandler<CapturePayPalOrderCommand, bool> _captureHandler;
        private readonly ICommandHandler<CreatePayPalOnboardingCommand, PayPalOnboardingResult> _onboardingHandler;
        private readonly ICommandHandler<CompletePayPalOnboardingCommand, bool> _completeOnboardingHandler;

        public PayPalController(ICommandHandler<CreatePayPalOrderCommand, PayPalOrderDto> createHandler, ICommandHandler<CapturePayPalOrderCommand, bool> captureHandler, ICommandHandler<CreatePayPalOnboardingCommand, PayPalOnboardingResult> onboardingHandler, ICommandHandler<CompletePayPalOnboardingCommand, bool> completeOnboardingHandler)
        {
            _createHandler = createHandler;
            _captureHandler = captureHandler;
            _onboardingHandler = onboardingHandler;
            _completeOnboardingHandler = completeOnboardingHandler;
        }

        [Authorize]
        [HttpPost("create-paypal-order")]
        public async Task<IActionResult> CreateOrder(CreatePayPalOrderCommand command, CancellationToken cancellationToken)
        {
            var result = await _createHandler.HandleAsync(command, cancellationToken);

            return Ok(result);
        }

        [Authorize]
        [HttpPost("capture")]
        public async Task<IActionResult> CaptureOrder(CapturePayPalOrderCommand command, CancellationToken cancellationToken)
        {
            var result = await _captureHandler.HandleAsync(command, cancellationToken);

            return Ok(result);
        }

        [Authorize]
        [HttpPost("onboarding")]
        public async Task<IActionResult>
        CreateOnboarding(CancellationToken cancellationToken)
        {
            var result =
                await _onboardingHandler.HandleAsync(
                    new CreatePayPalOnboardingCommand(),
                    cancellationToken);

            return Ok(result);
        }

        [Authorize]
        [HttpPost("onboarding/complete")]
        public async Task<IActionResult> CompleteOnboarding(
        CancellationToken cancellationToken)
        {
            var result =
                await _completeOnboardingHandler
                    .HandleAsync(
                        new CompletePayPalOnboardingCommand(),
                        cancellationToken);

            return Ok(result);
        }

    }
}
