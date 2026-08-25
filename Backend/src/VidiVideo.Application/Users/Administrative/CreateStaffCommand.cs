using VidiVideo.Application.Common;

namespace VidiVideo.Application.Users.Administrative;

public sealed record CreateStaffCommand(string UserName, string Email, string Password, string DisplayName, string Role) : ICommand<Guid>;
