using VidiVideo.Domain.Common;

namespace VidiVideo.Domain.Entities;

public sealed class Follow : AuditableEntity
{
    public Guid FollowerId { get; set; }
    public AppUser Follower { get; set; } = null!;
    public Guid CreatorId { get; set; }
    public AppUser Creator { get; set; } = null!;

    protected Follow() { }

    public Follow(Guid followerId, Guid creatorId)
    {
        FollowerId = followerId;
        CreatorId = creatorId;
    }
    public void RemoveFollow()
    {
        IsDeleted = true;
    }

    public void ReturnFollow()
    {
        IsDeleted = false;
    }
}
