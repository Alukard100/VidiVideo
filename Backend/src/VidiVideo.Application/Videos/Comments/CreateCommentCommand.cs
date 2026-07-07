using VidiVideo.Application.Common;

namespace VidiVideo.Application.Videos.Comments;

public sealed record CreateCommentCommand(Guid UserID, Guid VideoId, string Content) : ICommand<Guid>;
