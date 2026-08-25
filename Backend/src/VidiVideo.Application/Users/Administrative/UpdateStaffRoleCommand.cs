using VidiVideo.Application.Common;

namespace VidiVideo.Application.Users.Administrative;

public sealed record UpdateStaffRoleCommand(Guid TargetId, string Role) : ICommand<bool>;
