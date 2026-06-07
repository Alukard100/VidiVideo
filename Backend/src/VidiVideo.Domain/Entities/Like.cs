using VidiVideo.Domain.Common;

namespace VidiVideo.Domain.Entities;

public sealed class Like : AuditableEntity
{
    public Guid VideoId { get; set; }
    public Video Video { get; set; } = null!;
    public Guid UserId { get; set; }
    public AppUser User { get; set; } = null!;
}
