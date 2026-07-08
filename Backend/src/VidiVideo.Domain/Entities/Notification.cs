using VidiVideo.Domain.Common;
using VidiVideo.Domain.Enums;

namespace VidiVideo.Domain.Entities;

public class Notification : AuditableEntity
{
    public Guid UserId { get; set; }
    public AppUser User { get; set; } = null!;
    public string Title { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
    public bool IsRead { get; set; }
    public DateTime? ReadAtUtc { get; set; }
    public NotificationType Type { get; set; }

    protected Notification() { }

    public Notification(Guid userId, string title, string content, NotificationType type)
    {
        UserId = userId;
        Title = title;
        Content = content;
        IsRead = false;
        ReadAtUtc = null;
        Type = type;
    }

    public void ReadNotification()
    {
        IsRead = true;
        ReadAtUtc = DateTime.UtcNow;
    }
}
