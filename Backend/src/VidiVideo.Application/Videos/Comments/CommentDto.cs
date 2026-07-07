namespace VidiVideo.Application.Videos.Comments;

public sealed record CommentDto(Guid Id, string Content, DateTime CreatedAtUtc, DateTime? UpdatedAtUtc);
