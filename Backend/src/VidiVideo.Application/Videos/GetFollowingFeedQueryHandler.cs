using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;

namespace VidiVideo.Application.Videos;

public sealed class GetFollowingFeedQueryHandler : IQueryHandler<GetFollowingFeedQuery, PagedResult<VideoFeedDto>>
{
    private readonly IVideoRepository _videoRepository;
    private readonly IPaymentRepository _paymentRepository;
    private readonly ILikeRepository _likeRepository;
    private readonly ICurrentUser _currentUser;

    public GetFollowingFeedQueryHandler(
        IVideoRepository videoRepository,
        IPaymentRepository paymentRepository,
        ILikeRepository likeRepository,
        ICurrentUser currentUser)
    {
        _videoRepository = videoRepository;
        _paymentRepository = paymentRepository;
        _likeRepository = likeRepository;
        _currentUser = currentUser;
    }

    public async Task<PagedResult<VideoFeedDto>> HandleAsync(GetFollowingFeedQuery query, CancellationToken cancellationToken)
    {
        var userId = _currentUser.UserId
            ?? throw new UnauthorizedException("Must be logged in");

        var videos = await _videoRepository.GetFollowedFeedAsync(userId, query.Page, query.PageSize, cancellationToken);

        var totalCount = await _videoRepository.CountFollowedFeedAsync(userId, cancellationToken);

        var subscribedCreatorIds =
            await _paymentRepository.GetActiveSubscribedCreatorIdsAsync(userId);
        var likedVideos = await _likeRepository.GetLikedVideosByUserAsync(userId);
        var likedVideoIds = likedVideos.Select(video => video.Id).ToHashSet();

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
                video.CategoryId,
                video.Visibility,
                video.Likes.Count,
                video.Comments.Count,
                video.VideoViews.Count,
                isLocked,
                likedVideoIds.Contains(video.Id),
                video.CreatorId == userId);
        }).ToList();

        return new PagedResult<VideoFeedDto>(
            items, query.Page, query.PageSize, totalCount);

    }


}
