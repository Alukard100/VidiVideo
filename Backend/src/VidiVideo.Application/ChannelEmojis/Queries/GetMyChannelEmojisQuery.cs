using VidiVideo.Application.Common;

namespace VidiVideo.Application.ChannelEmojis.Queries;

public sealed record GetMyChannelEmojisQuery() : PagedRequest, IQuery<PagedResult<ChannelEmojiDto>>;
