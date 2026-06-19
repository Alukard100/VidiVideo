using VidiVideo.Application.Common;

namespace VidiVideo.Application.Hashtags;

public sealed record GetHashtagByIdQuery(Guid Id) : IQuery<HashtagDto>;
