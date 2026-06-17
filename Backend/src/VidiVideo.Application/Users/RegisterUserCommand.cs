using VidiVideo.Application.Common;

namespace VidiVideo.Application.Users
{
    public sealed record RegisterUserCommand(
        string UserName,
        string Email,
        string Password,
        string DisplayName)
        : ICommand<Guid>;
}
