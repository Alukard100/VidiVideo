using VidiVideo.Application.Common;

namespace VidiVideo.Application.Users
{
    public sealed record LoginUserCommand(
        string UserName,
        string Password)
        : ICommand<LoginUserResponse>;
}
