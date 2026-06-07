using VidiVideo.Domain.Common;

namespace VidiVideo.Domain.Entities;

public sealed class CreatorSubscription : AuditableEntity
{
    public Guid SubscriberId { get; set; }
    public AppUser Subscriber { get; set; } = null!;
    public Guid CreatorId { get; set; }
    public AppUser Creator { get; set; } = null!;
    public DateTime StartsAtUtc { get; set; }
    public DateTime EndsAtUtc { get; set; }
    public bool IsActive { get; set; }
}
