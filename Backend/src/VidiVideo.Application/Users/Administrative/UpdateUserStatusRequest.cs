using VidiVideo.Domain.Enums;

namespace VidiVideo.Application.Users.Administrative;

public sealed record UpdateUserStatusRequest(UserStatus Status);
