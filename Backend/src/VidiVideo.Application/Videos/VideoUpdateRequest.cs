using VidiVideo.Domain.Enums;

namespace VidiVideo.Application.Videos;

public sealed record VideoUpdateRequest(Guid VideoId, Guid CategoryId, string Caption, string ThumbnailUrl, VideoVisibility Visibility, bool IsPublished);
