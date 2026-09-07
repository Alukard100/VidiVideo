using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;
using VidiVideo.Application.Media;
using VidiVideo.Application.Messaging;

namespace VidiVideo.Application.ChannelEmojis.Commands;

public sealed class DeleteEmojiCommandHandler : ICommandHandler<DeleteEmojiCommand, bool>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IChannelEmojiRepository _channelEmojiRepository;
    private readonly ICurrentUser _currentUser;
    private readonly IMessagePublisher _messagePublisher;

    public DeleteEmojiCommandHandler(IUnitOfWork unitOfWork, IChannelEmojiRepository channelEmojiRepository, ICurrentUser currentUser, IMessagePublisher messagePublisher)
    {
        _unitOfWork = unitOfWork;
        _channelEmojiRepository = channelEmojiRepository;
        _currentUser = currentUser;
        _messagePublisher = messagePublisher;
    }

    public async Task<bool> HandleAsync(DeleteEmojiCommand command, CancellationToken cancellationToken)
    {
        var userId = _currentUser.UserId ?? throw new UnauthorizedException("Must be logged in");

        var emoji = await _channelEmojiRepository.GetByIdAsync(command.EmojiId, cancellationToken) ?? throw new NotFoundException("Emoji not found");
        if (emoji.CreatorId != userId) throw new ForbiddenException("You can only delete your own channel emojis.");

        var oldImageUrl = emoji.ImageUrl;

        _channelEmojiRepository.Remove(emoji);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        if (!string.IsNullOrWhiteSpace(oldImageUrl))
        {
            await _messagePublisher.PublishAsync(QueueNames.ImageCleanup, new OldImageCleanupRequested(oldImageUrl), cancellationToken);
        }

        return true;
    }
}
