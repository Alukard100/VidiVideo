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

        public NotificationController(ICommandHandler<MarkNotificationAsReadCommand, bool> markHandler, IQueryHandler<GetNotificationsQuery, PagedResult<NotificationMessage>> queryHandler)
        {
            _markHandler = markHandler;
            _queryHandler = queryHandler;
        }

        [HttpPatch("read")]
        public async Task<IActionResult> Read([FromBody] Guid notificationId, CancellationToken cancellationToken)
        {
            var command = new MarkNotificationAsReadCommand(notificationId);

            var result = await _markHandler.HandleAsync(command, cancellationToken);

            return Ok(result);
        }

        [HttpGet("mynotifications")]
        public async Task<IActionResult> GetNotifications([FromQuery] GetNotificationsQuery query, CancellationToken cancellationToken)
        {
            var notifications = await _queryHandler.HandleAsync(query, cancellationToken);

            return Ok(notifications);
        }


    }
}
