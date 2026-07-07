using VidiVideo.Application.Common;

namespace VidiVideo.Application.Videos.Comments;

public sealed record UpdateCommentCommand(Guid id, string content) : ICommand<Guid>;

