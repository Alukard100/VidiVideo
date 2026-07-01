using VidiVideo.Domain.Enums;

namespace VidiVideo.Application.Videos;

public sealed record VideoDto(
    Guid Id,
    string Caption,
    string VideoUrl,
    string ThumbnailUrl,
    string CreatorName,
    string CategoryName,
    bool IsPublished,
    VideoVisibility Visibility,
    int LikeCount,
    int CommentCount,
    List<string> Hashtags);
