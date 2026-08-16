using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;
using VidiVideo.Domain.Enums;

namespace VidiVideo.Application.Users.Activities;

public sealed class GetMyProfileQueryHandler : IQueryHandler<GetMyProfileQuery, CurrentUserProfileDto>
{
    private readonly IUserRepository _repo;
    private readonly ICurrentUser _currentUser;

    public GetMyProfileQueryHandler(IUserRepository repo, ICurrentUser currentUser)
    {
        _repo = repo;
        _currentUser = currentUser;
    }

    public async Task<CurrentUserProfileDto> HandleAsync(GetMyProfileQuery query, CancellationToken cancellationToken)
    {
        var userId = _currentUser.UserId
            ?? throw new UnauthorizedException("Must be logged in.");

        var user = await _repo.GetProfileByIdAsync(userId)
            ?? throw new NotFoundException("User doesn't exist.");

        var followers = await _repo.FollowersCountAsync(user.Id);
        var following = await _repo.FollowingCountAsync(user.Id);
        var publicVideos = user.Videos
            .Where(v => v.Visibility == VideoVisibility.Public)
            .Select(v => new ProfileVideoDto(v.Id, v.Caption, v.ThumbnailUrl, IsLocked: false))
            .ToList();
        var subscriberOnlyVideos = user.Videos
            .Where(v => v.Visibility == VideoVisibility.SubscribersOnly)
            .Select(v => new ProfileVideoDto(v.Id, v.Caption, v.ThumbnailUrl, IsLocked: false))
            .ToList();

        return new CurrentUserProfileDto(
            user.Id,
            user.UserName,
            user.DisplayName,
            user.Email,
            user.Bio,
            user.AvatarUrl,
            user.CountryId,
            user.Country?.Name,
            user.Status,
            followers,
            following,
            publicVideos,
            subscriberOnlyVideos);
    }
}
