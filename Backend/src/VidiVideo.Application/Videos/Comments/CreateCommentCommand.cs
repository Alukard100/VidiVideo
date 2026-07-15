using VidiVideo.Application.Common;

namespace VidiVideo.Application.Videos.Comments;

public sealed record CreateCommentCommand(Guid VideoId, string Content) : ICommand<Guid>;
