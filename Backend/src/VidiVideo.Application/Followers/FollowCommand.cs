using VidiVideo.Application.Common;

namespace VidiVideo.Application.Followers;

public sealed record FollowCommand(Guid Follower, Guid Creator) : ICommand<bool>;

