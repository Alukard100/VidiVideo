namespace VidiVideo.Application.ChannelEmojis;

public sealed record ChannelEmojiDto(Guid Id, Guid CreatorId, string CreatorName, string Code, string ImageUrl);
