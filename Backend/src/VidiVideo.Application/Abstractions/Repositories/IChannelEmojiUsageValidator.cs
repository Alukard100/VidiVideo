namespace VidiVideo.Application.Abstractions.Repositories;

public interface IChannelEmojiUsageValidator
{
    Task ValidateAsync(Guid userId, string text, CancellationToken cancellationToken);
}
