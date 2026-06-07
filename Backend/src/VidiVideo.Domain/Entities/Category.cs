using VidiVideo.Domain.Common;

namespace VidiVideo.Domain.Entities;

public sealed class Category : AuditableEntity
{
    public string Name { get; set; } = string.Empty;
    public ICollection<Video> Videos { get; set; } = [];
}
