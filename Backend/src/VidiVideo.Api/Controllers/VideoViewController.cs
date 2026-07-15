using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VidiVideo.Application.Common;
using VidiVideo.Application.VideoViews;

namespace VidiVideo.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class VideoViewController : ControllerBase
    {
        private readonly ICommandHandler<RecordVideoViewCommand, Guid> _commandHandler;
        public VideoViewController(ICommandHandler<RecordVideoViewCommand, Guid> commandHandler)
        {
            _commandHandler = commandHandler;
        }

        [Authorize]
        [HttpPost("record")]
        public async Task<IActionResult> Record([FromBody] RecordVideoViewRequest request, CancellationToken cancellationToken)
        {
            var command = new RecordVideoViewCommand(request.VideoId, request.WatchDurationSeconds, request.CompletionRate);

            var resultId = await _commandHandler.HandleAsync(command, cancellationToken);

            return Ok(resultId);
        }
    }
}
