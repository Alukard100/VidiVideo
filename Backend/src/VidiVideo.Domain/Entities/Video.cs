using VidiVideo.Domain.Common;
using VidiVideo.Domain.Enums;

namespace VidiVideo.Domain.Entities;

public sealed class Video : AuditableEntity
{
    public Guid CreatorId { get; private set; }
    public AppUser Creator { get; private set; } = null!;
    public Guid CategoryId { get; private set; }
    public Category Category { get; private set; } = null!;
    public string Caption { get; private set; } = string.Empty;
    public string VideoUrl { get; private set; } = string.Empty;
    public string ThumbnailUrl { get; private set; } = string.Empty;
    public VideoVisibility Visibility { get; private set; } = VideoVisibility.Public;
    public bool IsPublished { get; private set; } = true;

    public ICollection<Comment> Comments { get; private set; } = [];
    public ICollection<Like> Likes { get; private set; } = [];
    public ICollection<VideoHashtag> VideoHashtags { get; private set; } = [];
    protected Video() { }
    public Video(Guid creatorId, Guid categoryId, string caption, string videoUrl, string thumbnailUrl, VideoVisibility visibility, bool isPublished)
    {
        CreatorId = creatorId;
        CategoryId = categoryId;
        Caption = caption;
        VideoUrl = videoUrl;
        ThumbnailUrl = thumbnailUrl;
        Visibility = visibility;
        IsPublished = isPublished;
    }

    public void AddHashtags(
        IEnumerable<VideoHashtag> hashtags)
    {
        foreach (var hashtag in hashtags)
        {
            VideoHashtags.Add(hashtag);
        }
    }
}
