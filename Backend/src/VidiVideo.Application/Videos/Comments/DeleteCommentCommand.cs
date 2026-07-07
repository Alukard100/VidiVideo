using VidiVideo.Application.Common;

namespace VidiVideo.Application.Videos.Comments;

public sealed record DeleteCommentCommand(Guid Id) : ICommand<bool>;
