using VidiVideo.Application.Common;

namespace VidiVideo.Application.Videos;

public record GetFollowingFeedQuery
    : PagedRequest,
      IQuery<PagedResult<VideoFeedDto>>;