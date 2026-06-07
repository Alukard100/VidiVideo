using VidiVideo.Domain.Common;

namespace VidiVideo.Domain.Entities;

public sealed class Hashtag : AuditableEntity
{
    public string Name { get; set; } = string.Empty;
    public ICollection<VideoHashtag> VideoHashtags { get; set; } = [];
}
