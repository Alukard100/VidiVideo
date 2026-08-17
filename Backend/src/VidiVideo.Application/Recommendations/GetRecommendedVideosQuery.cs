using VidiVideo.Application.Common;
using VidiVideo.Application.Videos;

namespace VidiVideo.Application.Recommendations;

public sealed record GetRecommendedVideosQuery
    : PagedRequest,
      IQuery<PagedResult<VideoFeedDto>>;
