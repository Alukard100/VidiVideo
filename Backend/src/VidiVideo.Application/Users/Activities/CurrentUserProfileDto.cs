using VidiVideo.Domain.Enums;

namespace VidiVideo.Application.Users;

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
    int FollowersCount,
    int FollowingCount,
    IReadOnlyList<ProfileVideoDto> PublicVideos,
    IReadOnlyList<ProfileVideoDto> SubscriberOnlyVideos);
