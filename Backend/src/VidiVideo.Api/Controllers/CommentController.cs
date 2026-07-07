using Microsoft.AspNetCore.Mvc;
using VidiVideo.Application.Common;
using VidiVideo.Application.Videos.Comments;

namespace VidiVideo.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class CommentController : ControllerBase
    {
        private readonly ICommandHandler<CreateCommentCommand, Guid> _createHandler;
        private readonly ICommandHandler<DeleteCommentCommand, bool> _deleteHandler;
        private readonly ICommandHandler<UpdateCommentCommand, Guid> _updateHandler;
        private readonly IQueryHandler<GetVideoCommentsQuery, PagedResult<CommentDto>> _queryHandler;
        public CommentController(ICommandHandler<CreateCommentCommand, Guid> createHandler,
            ICommandHandler<DeleteCommentCommand, bool> deleteHandler,
            ICommandHandler<UpdateCommentCommand, Guid> updateHandler,
            IQueryHandler<GetVideoCommentsQuery, PagedResult<CommentDto>> queryHandler)
        {
            _createHandler = createHandler;
            _deleteHandler = deleteHandler;
            _updateHandler = updateHandler;
            _queryHandler = queryHandler;
        }

        [HttpPost("create")]
        public async Task<IActionResult> Create([FromBody] CreateCommentRequest request, CancellationToken cancellationToken)
        {
            var command = new CreateCommentCommand(request.UserId, request.VideoId, request.Content);

            var commentId = await _createHandler.HandleAsync(command, cancellationToken);

            return Ok(commentId);
        }

        [HttpPatch("update")]
        public async Task<IActionResult> Update([FromBody] UpdateCommentRequest request, CancellationToken cancellationToken)
        {
            var command = new UpdateCommentCommand(request.Id, request.Content);

            var commentId = await _updateHandler.HandleAsync(command, cancellationToken);

            return Ok(commentId);
        }

        [HttpDelete("{commentId:guid}")]
        public async Task<IActionResult> DeleteComment(Guid commentId, CancellationToken cancellationToken)
        {
            var command = new DeleteCommentCommand(commentId);

            var result = await _deleteHandler.HandleAsync(command, cancellationToken);

            return Ok(result);
        }

        [HttpGet("getComments")]
        public async Task<IActionResult> GetComments([FromQuery] GetVideoCommentsQuery query, CancellationToken cancellationToken)
        {
            var result = await _queryHandler.HandleAsync(query, cancellationToken);
            return Ok(result);
        }
    }
}
