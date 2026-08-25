using VidiVideo.Application.Common;

namespace VidiVideo.Application.Users.Administrative;

public sealed record DeleteStaffCommand(Guid TargetId) : ICommand<bool>;
