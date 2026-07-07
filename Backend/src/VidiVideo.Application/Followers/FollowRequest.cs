namespace VidiVideo.Application.Followers;

public sealed record FollowRequest(Guid CurrentUserId, Guid TargeTuserId);

