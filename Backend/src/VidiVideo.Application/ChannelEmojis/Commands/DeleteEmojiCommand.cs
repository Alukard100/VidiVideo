using VidiVideo.Application.Common;

namespace VidiVideo.Application.ChannelEmojis.Commands;

public sealed record DeleteEmojiCommand(Guid EmojiId) : ICommand<bool>;
