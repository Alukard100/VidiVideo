using VidiVideo.Application.Common;

namespace VidiVideo.Application.ChannelEmojis.Commands;

public sealed record CreateEmojiCommand(string Code, string ImageUrl) : ICommand<ChannelEmojiDto>;
