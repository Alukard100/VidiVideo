using VidiVideo.Domain.Common;

namespace VidiVideo.Domain.Entities;

public sealed class VideoView : AuditableEntity
{
    public Guid UserId { get; set; }
    public AppUser User { get; set; } = null!;
    public Guid VideoId { get; set; }
    public Video Video { get; set; } = null!;
    public int WatchDurationSeconds { get; set; }
    public decimal CompletionRate { get; set; }
}
