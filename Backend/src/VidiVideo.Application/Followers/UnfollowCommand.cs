using VidiVideo.Application.Common;

namespace VidiVideo.Application.Followers;

public sealed record UnfollowCommand(Guid Follower, Guid Creator) : ICommand<bool>;
