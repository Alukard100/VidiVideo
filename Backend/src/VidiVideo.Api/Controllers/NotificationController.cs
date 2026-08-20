using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VidiVideo.Application.Common;
using VidiVideo.Application.Notifications;

namespace VidiVideo.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class NotificationController : ControllerBase
    {
        private readonly ICommandHandler<MarkNotificationAsReadCommand, bool> _markHandler;
        private readonly IQueryHandler<GetNotificationsQuery, PagedResult<NotificationMessage>> _queryHandler;
        private readonly ICommandHandler<MarkAllNotificationsAsReadCommand, bool> _markAllHandler;

        public NotificationController(ICommandHandler<MarkNotificationAsReadCommand, bool> markHandler, IQueryHandler<GetNotificationsQuery, PagedResult<NotificationMessage>> queryHandler, ICommandHandler<MarkAllNotificationsAsReadCommand, bool> markAllHandler)
        {
            _markHandler = markHandler;
            _queryHandler = queryHandler;
            _markAllHandler = markAllHandler;
        }

        [Authorize]
        [HttpPatch("read")]
        public async Task<IActionResult> Read([FromBody] MarkNotificationReadRequest request, CancellationToken cancellationToken)
        {
            var command = new MarkNotificationAsReadCommand(request.NotificationId);

            var result = await _markHandler.HandleAsync(command, cancellationToken);

            return Ok(result);
        }

        [Authorize]
        [HttpGet("mynotifications")]
        public async Task<IActionResult> GetNotifications([FromQuery] GetNotificationsQuery query, CancellationToken cancellationToken)
        {
            var notifications = await _queryHandler.HandleAsync(query, cancellationToken);

            return Ok(notifications);
        }

        [Authorize]
        [HttpPatch("read-all")]
        public async Task<IActionResult> ReadAll(CancellationToken cancellationToken)
        {
            var result =
                await _markAllHandler.HandleAsync(
                    new MarkAllNotificationsAsReadCommand(),
                    cancellationToken);

            return Ok(result);
        }
    }
}
