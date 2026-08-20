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
        Guid CategoryId,
        VideoVisibility Visibility,
        int LikeCount,
        int CommentCount,
        int ViewCount,
        bool IsLocked,
        bool IsLiked,
        bool CanEdit,
        string? RecommendationReason = null,
        double? RecommendationScore = null);
}
