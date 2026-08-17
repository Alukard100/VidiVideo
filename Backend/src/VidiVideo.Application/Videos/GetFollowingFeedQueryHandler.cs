using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;

namespace VidiVideo.Application.Videos;

public sealed class GetFollowingFeedQueryHandler : IQueryHandler<GetFollowingFeedQuery, PagedResult<VideoFeedDto>>
{
    private readonly IVideoRepository _videoRepository;
    private readonly IPaymentRepository _paymentRepository;
    private readonly ICurrentUser _currentUser;

    public GetFollowingFeedQueryHandler(
        IVideoRepository videoRepository,
        IPaymentRepository paymentRepository,
        ICurrentUser currentUser)
    {
        _videoRepository = videoRepository;
        _paymentRepository = paymentRepository;
        _currentUser = currentUser;
    }

    public async Task<PagedResult<VideoFeedDto>> HandleAsync(GetFollowingFeedQuery query, CancellationToken cancellationToken)
    {
        var userId = _currentUser.UserId
            ?? throw new UnauthorizedException("Must be logged in");

        var videos = await _videoRepository.GetFollowedFeedAsync(userId, query.Page, query.PageSize);

        var totalCount = await _videoRepository.CountFollowedFeedAsync(userId);

        var subscribedCreatorIds =
            await _paymentRepository.GetActiveSubscribedCreatorIdsAsync(userId);

        var items = videos.Select(video =>
        {
            var isLocked =
                video.Visibility == Domain.Enums.VideoVisibility.SubscribersOnly &&
                !subscribedCreatorIds.Contains(video.CreatorId);

            return new VideoFeedDto(
                video.Id,
                video.Caption,
                isLocked ? null : $"/api/Video/{video.Id}/stream",
                video.ThumbnailUrl,
                video.CreatorId,
                video.Creator.DisplayName,
                video.Creator.AvatarUrl,
                video.Visibility,
                video.Likes.Count,
                video.Comments.Count,
                video.VideoViews.Count,
                isLocked);
        }).ToList();

        return new PagedResult<VideoFeedDto>(
            items, query.Page, query.PageSize, totalCount);

    }


}
