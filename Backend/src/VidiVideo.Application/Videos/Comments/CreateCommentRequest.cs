namespace VidiVideo.Application.Videos.Comments;

public sealed record CreateCommentRequest(Guid UserId, Guid VideoId, string Content);

