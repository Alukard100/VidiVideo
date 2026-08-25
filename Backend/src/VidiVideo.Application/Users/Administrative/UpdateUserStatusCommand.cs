using VidiVideo.Application.Common;
using VidiVideo.Domain.Enums;

namespace VidiVideo.Application.Users.Administrative;

public sealed record UpdateUserStatusCommand(
    Guid UserId,
    UserStatus Status)
    : ICommand<bool>;
