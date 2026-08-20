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
    private readonly IFollowersRepository _followersRepository;

    public GetUserProfileQueryHandler(IUserRepository repo, ICurrentUser currentUser, IFollowersRepository followersRepository)
    {
        _repo = repo;
        _currentUser = currentUser;
        _followersRepository = followersRepository;

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
        var isFollowing = currentUserId.HasValue && !isOwnProfile && await _followersRepository.IsFollowingAsync(currentUserId.Value, user.Id);

        var publicVideos = user.Videos
            .Where(v => v.Visibility == VideoVisibility.Public && !v.IsDeleted && (v.IsPublished || isOwnProfile))
            .OrderByDescending(v => v.CreatedAtUtc)
            .Select(v => new ProfileVideoDto(v.Id, v.Caption, v.ThumbnailUrl, v.Visibility, v.IsPublished, IsLocked: false))
            .ToList();
        var subscriberOnlyVideos = user.Videos
            .Where(v => v.Visibility == VideoVisibility.SubscribersOnly && !v.IsDeleted && (isOwnProfile || v.IsPublished))
            .OrderByDescending(v => v.CreatedAtUtc)
            .Select(v => new ProfileVideoDto(v.Id, v.Caption, v.ThumbnailUrl, v.Visibility, v.IsPublished, IsLocked: !isSubscribed))
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
            isFollowing,
            publicVideos,
            subscriberOnlyVideos);
    }
}
