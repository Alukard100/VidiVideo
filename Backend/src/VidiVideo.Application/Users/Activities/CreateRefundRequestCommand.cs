using VidiVideo.Application.Common;

namespace VidiVideo.Application.Users.Activities;

public sealed record CreateRefundRequestCommand(Guid CreatorId) : ICommand<Guid>;
