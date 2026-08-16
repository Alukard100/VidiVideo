using VidiVideo.Application.Common;
using VidiVideo.Application.Users;

public sealed record GetUserProfileQuery(Guid UserId)
    : IQuery<UserProfileDto>;