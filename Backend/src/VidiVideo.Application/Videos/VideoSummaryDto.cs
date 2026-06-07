namespace VidiVideo.Application.Videos;

public sealed record VideoSummaryDto(
    Guid Id,
    string Caption,
    string CreatorDisplayName,
    string ThumbnailUrl,
    string Visibility,
    int LikeCount,
    int CommentCount);
