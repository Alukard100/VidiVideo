namespace VidiVideo.Application.Recommendations;

public sealed record RecommendedVideoDto(
    Guid Id,
    string Caption,
    string? VideoUrl,
    string ThumbnailUrl,
    Guid CreatorId,
    string CreatorDisplayName,
    string Visibility,
    int LikeCount,
    int CommentCount,
    int ViewCount,
    bool IsLocked,
    double RecommendationScore);