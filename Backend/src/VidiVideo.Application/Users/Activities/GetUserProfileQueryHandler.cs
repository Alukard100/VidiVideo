using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;
using VidiVideo.Application.Users;
using VidiVideo.Domain.Enums;

public sealed class GetUserProfileQueryHandler
    : IQueryHandler<GetUserProfileQuery, UserProfileDto>
{
    private readonly IUserRepository _repo;
    private readonly ICurrentUser _currentUser;
    private readonly IVideoRepository _videoRepository;

    public GetUserProfileQueryHandler(IUserRepository repo, ICurrentUser currentUser, IVideoRepository videoRepository)
    {
        _repo = repo;
        _currentUser = currentUser;
        _videoRepository = videoRepository;
    }

    public async Task<UserProfileDto> HandleAsync(
        GetUserProfileQuery query,
        CancellationToken cancellationToken)
    {
        var user = await _repo.GetProfileByIdAsync(query.UserId)
            ?? throw new NotFoundException("User doesn't exist.");

        var followers = await _repo.FollowersCountAsync(user.Id);
        var following = await _repo.FollowingCountAsync(user.Id);
        var currentUserId = _currentUser.UserId;
        var isOwnProfile = currentUserId == user.Id;
        var isSubscribed = isOwnProfile ||
            (currentUserId.HasValue &&
             await _repo.HasActiveSubscriptionAsync(currentUserId.Value, user.Id));

        var publicVideos = user.Videos
            .Where(v => v.Visibility == VideoVisibility.Public)
            .OrderByDescending(v => v.CreatedAtUtc)
            .Select(v => new ProfileVideoDto(v.Id, v.Caption, v.ThumbnailUrl, IsLocked: false))
            .ToList();
        var subscriberOnlyVideos = user.Videos
            .Where(v => v.Visibility == VideoVisibility.SubscribersOnly)
            .OrderByDescending(v => v.CreatedAtUtc)
            .Select(v => new ProfileVideoDto(v.Id, v.Caption, v.ThumbnailUrl, IsLocked: !isSubscribed))
            .ToList();

        return new UserProfileDto(
            user.Id,
            user.UserName,
            user.DisplayName,
            user.Bio,
            user.AvatarUrl,
            user.CountryId,
            user.Country?.Name,
            followers,
            following,
            isSubscribed,
            publicVideos,
            subscriberOnlyVideos);
    }
}
