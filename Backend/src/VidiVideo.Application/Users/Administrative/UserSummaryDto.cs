namespace VidiVideo.Application.Users.Administrative;

public sealed record UserSummaryDto(
    Guid Id,
    string UserName,
    string DisplayName,
    string Email,
    string? AvatarUrl,
    DateTime CreatedAtUtc,
    int VideoCount,
    int FollowersCount,
    string Status);
