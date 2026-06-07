using VidiVideo.Domain.Common;
using VidiVideo.Domain.Enums;

namespace VidiVideo.Domain.Entities;

public sealed class Video : AuditableEntity
{
    public Guid CreatorId { get; set; }
    public AppUser Creator { get; set; } = null!;
    public Guid CategoryId { get; set; }
    public Category Category { get; set; } = null!;
    public string Caption { get; set; } = string.Empty;
    public string VideoUrl { get; set; } = string.Empty;
    public string ThumbnailUrl { get; set; } = string.Empty;
    public VideoVisibility Visibility { get; set; } = VideoVisibility.Public;
    public bool IsPublished { get; set; } = true;

    public ICollection<Comment> Comments { get; set; } = [];
    public ICollection<Like> Likes { get; set; } = [];
    public ICollection<VideoHashtag> VideoHashtags { get; set; } = [];
}
