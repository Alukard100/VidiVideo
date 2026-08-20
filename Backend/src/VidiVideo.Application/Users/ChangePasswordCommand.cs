using VidiVideo.Application.Common;

namespace VidiVideo.Application.Users;

public sealed record ChangePasswordCommand(string OldPassword, string NewPassword) : ICommand<bool>;
