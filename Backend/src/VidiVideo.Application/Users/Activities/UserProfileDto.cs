namespace VidiVideo.Application.Users;

public sealed record UserProfileDto(
    Guid Id,
    string UserName,
    string DisplayName,
    string? Bio,
    string? AvatarUrl,
    Guid? CountryId,
    string? CountryName,
    int FollowersCount,
    int FollowingCount,
    bool IsSubscribed,
    IReadOnlyList<ProfileVideoDto> PublicVideos,
    IReadOnlyList<ProfileVideoDto> SubscriberOnlyVideos);
