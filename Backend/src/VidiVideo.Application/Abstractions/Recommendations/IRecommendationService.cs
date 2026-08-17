using VidiVideo.Application.Common;
using VidiVideo.Application.Videos;

namespace VidiVideo.Application.Abstractions.Recommendations;

public interface IRecommendationService
{
    Task<PagedResult<VideoFeedDto>> GetRecommendedVideosAsync(
        Guid? userId,
        int page,
        int pageSize,
        CancellationToken cancellationToken);
}