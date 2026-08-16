using VidiVideo.Application.Common;

namespace VidiVideo.Application.Recommendations;

public sealed record GetRecommendedVideosQuery
    : PagedRequest,
      IQuery<PagedResult<RecommendedVideoDto>>;
