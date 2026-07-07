using VidiVideo.Domain.Enums;

namespace VidiVideo.Application.Videos;

public sealed record VideoUpdateRequest(Guid videoId, Guid categoryId, string caption, string thumbnailUrl, VideoVisibility visibility, bool isPublished);
