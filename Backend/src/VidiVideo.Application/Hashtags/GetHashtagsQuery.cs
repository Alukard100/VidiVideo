using VidiVideo.Application.Common;

namespace VidiVideo.Application.Hashtags
{
    public sealed record GetHashtagsQuery : PagedRequest, IQuery<PagedResult<HashtagDto>>
    {
        public string? Search { get; init; }
    }

}
