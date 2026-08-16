using VidiVideo.Application.Common;
using VidiVideo.Application.Recommendations;

namespace VidiVideo.Application.Abstractions.Recommendations;

public interface IRecommendationService
{
    Task<PagedResult<RecommendedVideoDto>> GetRecommendedVideosAsync(
        Guid? userId,
        int page,
        int pageSize,
        CancellationToken cancellationToken);
}