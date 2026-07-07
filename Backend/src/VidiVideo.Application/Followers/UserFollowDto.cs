namespace VidiVideo.Application.Followers;

public sealed record UserFollowDto(Guid Id, string DisplayName, string? AvatarUrl, bool IsFollowing);
