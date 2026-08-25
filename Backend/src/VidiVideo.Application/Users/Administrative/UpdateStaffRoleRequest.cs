namespace VidiVideo.Application.Users.Administrative;

public sealed record UpdateStaffRoleRequest(Guid TargetId, string Role);
