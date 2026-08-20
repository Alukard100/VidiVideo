using VidiVideo.Domain.Enums;

namespace VidiVideo.Application.Videos;

public sealed record VideoDto(
    Guid Id,
    string Caption,
    string? VideoUrl,
    string ThumbnailUrl,
    Guid CreatorId,
    string CreatorDisplayName,
    string? CreatorAvatarUrl,
    Guid CategoryId,
    string CategoryName,
    bool IsPublished,
    VideoVisibility Visibility,
    int LikeCount,
    int CommentCount,
    int ViewCount,
    bool IsLocked,
    bool IsLiked,
    bool CanEdit,
    List<string> Hashtags);
