namespace VidiVideo.Application.Videos.Comments;

public sealed record CreateCommentRequest(Guid VideoId, string Content);

