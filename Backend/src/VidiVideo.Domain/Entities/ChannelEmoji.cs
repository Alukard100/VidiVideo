using VidiVideo.Domain.Common;

namespace VidiVideo.Domain.Entities;

public sealed class ChannelEmoji : AuditableEntity
{
    public Guid CreatorId { get; private set; }
    public AppUser Creator { get; private set; } = null!;
    public string Code { get; private set; } = string.Empty;
    public string ImageUrl { get; private set; } = string.Empty;
    protected ChannelEmoji() { }

    public ChannelEmoji(Guid creatorId, string code, string imageUrl)
    {
        CreatorId = creatorId;
        Code = code;
        ImageUrl = imageUrl;
    }

    public void UpdateCode(string code)
    {
        Code = code;
        UpdatedAtUtc = DateTime.UtcNow;
    }

    public void UpdateImage(string imageUrl)
    {
        ImageUrl = imageUrl;
        UpdatedAtUtc = DateTime.UtcNow;
    }

    public void Remove()
    {
        IsDeleted = true;
        UpdatedAtUtc = DateTime.UtcNow;
    }

}
