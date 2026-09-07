using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VidiVideo.Application.ChannelEmojis;
using VidiVideo.Application.ChannelEmojis.Commands;
using VidiVideo.Application.ChannelEmojis.Queries;
using VidiVideo.Application.Common;

namespace VidiVideo.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class EmojiController : ControllerBase
    {
        private readonly ICommandHandler<CreateEmojiCommand, ChannelEmojiDto> _createHandler;
        private readonly ICommandHandler<DeleteEmojiCommand, bool> _deleteHandler;
        private readonly IQueryHandler<GetMyChannelEmojisQuery, PagedResult<ChannelEmojiDto>> _getMineHandler;
        private readonly IQueryHandler<GetAvailableChannelEmojisQuery, PagedResult<ChannelEmojiDto>> _getAvailableHandler;

        public EmojiController(ICommandHandler<CreateEmojiCommand, ChannelEmojiDto> createHandler, ICommandHandler<DeleteEmojiCommand, bool> deleteHandler, IQueryHandler<GetMyChannelEmojisQuery, PagedResult<ChannelEmojiDto>> getMineHandler, IQueryHandler<GetAvailableChannelEmojisQuery, PagedResult<ChannelEmojiDto>> getAvailableHandler)
        {
            _createHandler = createHandler;
            _deleteHandler = deleteHandler;
            _getMineHandler = getMineHandler;
            _getAvailableHandler = getAvailableHandler;
        }

        [Authorize]
        [HttpGet("mine")]
        public async Task<IActionResult> GetMine([FromQuery] GetMyChannelEmojisQuery query, CancellationToken cancellationToken)
        {
            var result = await _getMineHandler.HandleAsync(query, cancellationToken);
            return Ok(result);
        }

        [Authorize]
        [HttpGet("available")]
        public async Task<IActionResult> GetAvailable([FromQuery] GetAvailableChannelEmojisQuery query, CancellationToken cancellationToken)
        {
            var result = await _getAvailableHandler.HandleAsync(query, cancellationToken);
            return Ok(result);
        }

        [Authorize]
        [HttpDelete("{emojiId:guid}")]
        public async Task<IActionResult> Delete(Guid emojiId, CancellationToken cancellationToken)
        {
            var command = new DeleteEmojiCommand(emojiId);
            var result = await _deleteHandler.HandleAsync(command, cancellationToken);
            return Ok(result);
        }

        [Authorize]
        [HttpPost("upload-emoji")]
        [Consumes("multipart/form-data")]
        [RequestSizeLimit(5242880)]
        public async Task<IActionResult> UploadEmoji([FromForm] string code, [FromForm] IFormFile formFile, CancellationToken cancellationToken)
        {
            if (formFile is null || formFile.Length == 0)
                return BadRequest("Emoji image is required");

            await using var stream = formFile.OpenReadStream();

            var command = new CreateEmojiCommand(code, stream, formFile.FileName);

            var result = await _createHandler.HandleAsync(command, cancellationToken);

            return Ok(result);
        }
    }
}
