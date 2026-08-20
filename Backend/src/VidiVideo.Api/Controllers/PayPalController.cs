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

        public PayPalController(ICommandHandler<CreatePayPalOrderCommand, PayPalOrderDto> createHandler, ICommandHandler<CapturePayPalOrderCommand, bool> captureHandler)
        {
            _createHandler = createHandler;
            _captureHandler = captureHandler;
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

    }
}
