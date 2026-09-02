using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;
using VidiVideo.Domain.Entities;

namespace VidiVideo.Application.ChannelEmojis.Commands;

public sealed class CreateEmojiCommandHandler : ICommandHandler<CreateEmojiCommand, ChannelEmojiDto>
{
    private readonly ICurrentUser _currentUser;
    private readonly IUnitOfWork _unitOfWork;
    private readonly IChannelEmojiRepository _emojiRepository;
    private readonly IUserRepository _userRepository;

    private const int MaxemojisPerCreator = 3;

    public CreateEmojiCommandHandler(ICurrentUser currentUser, IUnitOfWork unitOfWork, IChannelEmojiRepository emojiRepository, IUserRepository userRepository)
    {
        _currentUser = currentUser;
        _unitOfWork = unitOfWork;
        _emojiRepository = emojiRepository;
        _userRepository = userRepository;
    }

    public async Task<ChannelEmojiDto> HandleAsync(CreateEmojiCommand command, CancellationToken cancellationToken)
    {
        var userId = _currentUser.UserId ?? throw new UnauthorizedException("Must be logged in");

        var creator = await _userRepository.GetByIdAsync(userId) ?? throw new NotFoundException("User not found");
        if (!creator.HasConnectedPayPal) throw new ValidationException("Connect PayPal before creating channel emojis.");

        var code = command.Code.Trim();
        if (string.IsNullOrWhiteSpace(code)) throw new ValidationException("Emoji code is required.");
        if (code.Length > 32) throw new ValidationException("Emoji code cannot exceed 32 characters.");
        if (!code.All(c => char.IsLetterOrDigit(c) || c == '_')) throw new ValidationException("Emoji code may contain only letters, numbers and underscores.");

        var count = await _emojiRepository.CountByCreatorAsync(userId, cancellationToken);
        if (count >= MaxemojisPerCreator) throw new ValidationException("A creator can have at most 3 channel emojis, remove an emoji before adding a new one.");
        var existing = await _emojiRepository.GetByCreatorAndCodeAsync(userId, code, cancellationToken);
        if (existing is not null) throw new ConflictException("An emoji with this code already exists.");

        var emoji = new ChannelEmoji(userId, code, command.ImageUrl);

        await _emojiRepository.AddAsync(emoji, cancellationToken);

        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return new ChannelEmojiDto(emoji.Id, emoji.CreatorId, creator.DisplayName, emoji.Code, emoji.ImageUrl);

    }
}
