namespace VidiVideo.Domain.Entities;

public sealed class VideoHashtag
{
    public Guid VideoId { get; set; }
    public Video Video { get; set; } = null!;
    public Guid HashtagId { get; set; }
    public Hashtag Hashtag { get; set; } = null!;

    protected VideoHashtag() { }

    public VideoHashtag(Hashtag hashtag)
    {
        Hashtag = hashtag;
        HashtagId = hashtag.Id;
    }
}
