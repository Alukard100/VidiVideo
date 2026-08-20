using VidiVideo.Domain.Enums;

namespace VidiVideo.Application.Users;

public sealed record ProfileVideoDto(
    Guid Id,
    string Caption,
    string ThumbnailUrl,
    VideoVisibility Visibility,
    bool IsPublished,
    bool IsLocked);
