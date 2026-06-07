using VidiVideo.Domain.Common;

namespace VidiVideo.Domain.Entities;

public sealed class SearchHistory : AuditableEntity
{
    public Guid UserId { get; set; }
    public AppUser User { get; set; } = null!;
    public string Query { get; set; } = string.Empty;
}
