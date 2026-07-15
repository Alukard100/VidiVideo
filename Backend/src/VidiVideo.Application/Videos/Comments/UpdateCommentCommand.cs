using VidiVideo.Application.Common;

namespace VidiVideo.Application.Videos.Comments;

public sealed record UpdateCommentCommand(Guid Id, string Content) : ICommand<Guid>;

