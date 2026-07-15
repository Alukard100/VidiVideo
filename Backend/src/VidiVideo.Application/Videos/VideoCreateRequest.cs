using VidiVideo.Domain.Enums;

namespace VidiVideo.Application.Videos;

public sealed record VideoCreateRequest(
        Guid CategoryId,
        string Caption,
        string VideoUrl,
        string ThumbnailUrl,
        VideoVisibility Visibility,
        bool IsPublished);
