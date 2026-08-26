using VidiVideo.Domain.Enums;

namespace VidiVideo.Application.Users.Activities;

public sealed record CurrentUserProfileDto(
    Guid Id,
    string UserName,
    string DisplayName,
    string Email,
    string? Bio,
    string? AvatarUrl,
    Guid? CountryId,
    string? CountryName,
    UserStatus Status,
    bool HasConnectedPayPal,
    int FollowersCount,
    int FollowingCount,
    IReadOnlyList<ProfileVideoDto> PublicVideos,
    IReadOnlyList<ProfileVideoDto> SubscriberOnlyVideos);
