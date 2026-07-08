namespace VidiVideo.Application.Notifications;

public sealed record NotificationMessage(
    Guid RecipientId,
    string Title,
    string Body,
    string Type,
    bool IsRead,
    DateTime CreatedAtUtc);
