using VidiVideo.Application.Common;

namespace VidiVideo.Application.Hashtags
{
    public sealed record GetHashtagsQuery() : IQuery<List<HashtagDto>>;

}
