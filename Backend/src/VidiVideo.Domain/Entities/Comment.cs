using VidiVideo.Domain.Common;

namespace VidiVideo.Domain.Entities;

public sealed class Comment : AuditableEntity
{
    public Guid VideoId { get; set; }
    public Video Video { get; set; } = null!;
    public Guid AuthorId { get; set; }
    public AppUser Author { get; set; } = null!;
    public string Body { get; set; } = string.Empty;
    protected Comment() { }

    public Comment(Guid videoId, Guid authorId, string body)
    {
        VideoId = videoId;
        AuthorId = authorId;
        Body = body;
    }

    public void UpdateComment(string newContent)
    {
        Body = newContent;
        UpdatedAtUtc = DateTime.UtcNow;
    }

    public void Remove()
    {
        IsDeleted = true;
        UpdatedAtUtc = DateTime.UtcNow;
    }


}
