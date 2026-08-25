namespace VidiVideo.Application.Users.Administrative;

public sealed record StaffSummaryDto(
    Guid Id,
    string UserName,
    string Email,
    string DisplayName,
    string? AvatarUrl,
    string Role,
    DateTime CreatedAtUtc);
