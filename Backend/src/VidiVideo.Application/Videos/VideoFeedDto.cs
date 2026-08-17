using VidiVideo.Domain.Enums;

namespace VidiVideo.Application.Videos
{
    public sealed record VideoFeedDto(
        Guid Id,
        string Caption,
        string? VideoUrl,
        string ThumbnailUrl,
        Guid CreatorId,
        string CreatorDisplayName,
        string? CreatorAvatarUrl,
        VideoVisibility Visibility,
        int LikeCount,
        int CommentCount,
        int ViewCount,
        bool IsLocked,
        string? RecommendationReason = null,
        double? RecommendationScore = null);
}
