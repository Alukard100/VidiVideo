using VidiVideo.Application.Common;

namespace VidiVideo.Application.Videos.Comments;

public sealed record GetVideoCommentsQuery : PagedRequest, IQuery<PagedResult<CommentDto>>
{
    public Guid videoId { get; set; }
}
