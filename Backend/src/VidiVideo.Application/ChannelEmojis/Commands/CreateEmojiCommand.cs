using VidiVideo.Application.Common;

namespace VidiVideo.Application.ChannelEmojis.Commands;

public sealed record CreateEmojiCommand(string Code, Stream ImageStream, string FileName) : ICommand<ChannelEmojiDto>;
