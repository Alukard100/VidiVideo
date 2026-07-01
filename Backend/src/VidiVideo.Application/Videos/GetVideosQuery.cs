using VidiVideo.Application.Common;

namespace VidiVideo.Application.Videos;

public sealed record GetVideosQuery : PagedRequest, IQuery<PagedResult<VideoSummaryDto>>
{
    public string? Search { get; init; }
    public Guid? CategoryId { get; init; }
    public List<string> Hashtags { get; init; } = [];
}
