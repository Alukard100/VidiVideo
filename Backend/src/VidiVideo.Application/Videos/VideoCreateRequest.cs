using VidiVideo.Domain.Enums;

namespace VidiVideo.Application.Videos;

public sealed record VideoCreateRequest(
        Guid creatorId,
        Guid categoryId,
        string caption,
        string videoUrl,
        string thumbnailUrl,
        VideoVisibility visibility,
        bool isPublished);
