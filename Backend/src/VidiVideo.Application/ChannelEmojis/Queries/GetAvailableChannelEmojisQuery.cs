using VidiVideo.Application.Common;

namespace VidiVideo.Application.ChannelEmojis.Queries;

public sealed record GetAvailableChannelEmojisQuery() : PagedRequest, IQuery<PagedResult<ChannelEmojiDto>>;
