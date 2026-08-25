using VidiVideo.Domain.Common;

namespace VidiVideo.Domain.Entities;

public sealed class CreatorSubscription : AuditableEntity
{
    public Guid SubscriberId { get; private set; }
    public AppUser Subscriber { get; set; } = null!;
    public Guid CreatorId { get; private set; }
    public AppUser Creator { get; set; } = null!;
    public DateTime? StartsAtUtc { get; private set; }
    public DateTime? EndsAtUtc { get; private set; }
    public bool IsActive { get; private set; }

    protected CreatorSubscription() { }

    public CreatorSubscription(Guid subscriberId, Guid creatorId)
    {
        SubscriberId = subscriberId;
        CreatorId = creatorId;
        IsActive = false;
    }

    public void Activate()
    {
        StartsAtUtc = DateTime.UtcNow;
        EndsAtUtc = DateTime.UtcNow.AddMonths(1);
        IsActive = true;
    }

    public void Deactivate()
    {
        IsActive = false;
        EndsAtUtc = DateTime.UtcNow;
        UpdatedAtUtc = DateTime.UtcNow;
    }
}
