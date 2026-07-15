using VidiVideo.Application.Common;

namespace VidiVideo.Application.Followers;

public sealed record FollowCommand(Guid Creator) : ICommand<bool>;

