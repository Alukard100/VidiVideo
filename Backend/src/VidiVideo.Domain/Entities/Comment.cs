using VidiVideo.Domain.Common;

namespace VidiVideo.Domain.Entities;

public sealed class Comment : AuditableEntity
{
    public Guid VideoId { get; set; }
    public Video Video { get; set; } = null!;
    public Guid AuthorId { get; set; }
    public AppUser Author { get; set; } = null!;
    public string Body { get; set; } = string.Empty;
}
