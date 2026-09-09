using VidiVideo.Application.Common;

namespace VidiVideo.Application.Users;

public sealed record ResetPasswordCommand(string Email, string Code, string NewPassword) : ICommand<bool>;
