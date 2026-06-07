using VidiVideo.Domain.Common;

namespace VidiVideo.Domain.Entities;

public sealed class Follow : AuditableEntity
{
    public Guid FollowerId { get; set; }
    public AppUser Follower { get; set; } = null!;
    public Guid CreatorId { get; set; }
    public AppUser Creator { get; set; } = null!;
}
