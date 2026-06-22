namespace VidiVideo.Application.Videos;

public sealed record VideoDto(
    Guid Id,
    string Caption,
    string VideoUrl,
    string ThumbnailUrl,
    string CreatorName,
    string CategoryName,
    bool IsPublished);
