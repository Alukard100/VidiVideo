using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Recommendations;
using VidiVideo.Application.Common;
using VidiVideo.Application.Videos;

namespace VidiVideo.Application.Recommendations;

public sealed class GetRecommendedVideosQueryHandler
    : IQueryHandler<
        GetRecommendedVideosQuery,
        PagedResult<VideoFeedDto>>
{
    private readonly IRecommendationService _recommendationService;
    private readonly ICurrentUser _currentUser;

    public GetRecommendedVideosQueryHandler(
        IRecommendationService recommendationService,
        ICurrentUser currentUser)
    {
        _recommendationService = recommendationService;
        _currentUser = currentUser;
    }

    public async Task<PagedResult<VideoFeedDto>> HandleAsync(
        GetRecommendedVideosQuery query,
        CancellationToken cancellationToken)
    {
        var userId = _currentUser.UserId;

        return await _recommendationService.GetRecommendedVideosAsync(
            userId,
            query.Page,
            query.PageSize,
            cancellationToken);
    }
}