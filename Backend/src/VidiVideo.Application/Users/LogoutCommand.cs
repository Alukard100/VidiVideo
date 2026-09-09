using VidiVideo.Application.Common;

namespace VidiVideo.Application.Users;

public sealed record LogoutCommand
    : ICommand<bool>;
