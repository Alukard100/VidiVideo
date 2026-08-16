namespace VidiVideo.Application.Users;

public sealed record ProfileVideoDto(
    Guid Id,
    string Caption,
    string ThumbnailUrl,
    bool IsLocked);
