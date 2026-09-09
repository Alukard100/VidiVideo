using VidiVideo.Application.Common;

namespace VidiVideo.Application.Users;

public sealed record ForgetPasswordCommand(string Email) : ICommand<bool>;
