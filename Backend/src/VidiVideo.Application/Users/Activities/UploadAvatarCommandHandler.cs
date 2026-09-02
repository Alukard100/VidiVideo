using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;
using VidiVideo.Application.Media;
using VidiVideo.Application.Messaging;
using VidiVideo.Domain.Enums;

public sealed class UploadAvatarCommandHandler
    : ICommandHandler<UploadAvatarCommand, string>
{
    private readonly IImageStorageService _imageStorage;
    private readonly IUserRepository _userRepository;
    private readonly ICurrentUser _currentUser;
    private readonly IUnitOfWork _unitOfWork;
    private readonly IMessagePublisher _messagePublisher;
    private readonly IImageProcessor _imageProcessor;

    public UploadAvatarCommandHandler(
        IImageStorageService imageStorage,
        IUserRepository userRepository,
        ICurrentUser currentUser,
        IUnitOfWork unitOfWork,
        IMessagePublisher messagePublisher,
        IImageProcessor imageProcessor)
    {
        _imageStorage = imageStorage;
        _userRepository = userRepository;
        _currentUser = currentUser;
        _unitOfWork = unitOfWork;
        _messagePublisher = messagePublisher;
        _imageProcessor = imageProcessor;
    }

    public async Task<string> HandleAsync(
        UploadAvatarCommand command,
        CancellationToken cancellationToken)
    {
        var userId = _currentUser.UserId
            ?? throw new UnauthorizedException("Must be logged in.");

        var user = await _userRepository.GetByIdAsync(userId)
            ?? throw new NotFoundException("User doesn't exist.");

        var oldAvatar = user.AvatarUrl;


        var processedImage = await _imageProcessor.ProcessAsync(command.ImageStream, command.FileName, ImagePurpose.ProfilePicture, cancellationToken);

        var avatarUrl = await _imageStorage.UploadAsync(processedImage, cancellationToken);

        user.UpdateAvatar(avatarUrl);

        await _unitOfWork.SaveChangesAsync(cancellationToken);

        if (!string.IsNullOrWhiteSpace(oldAvatar) && !string.Equals(oldAvatar, avatarUrl, StringComparison.OrdinalIgnoreCase))
        {
            await _messagePublisher.PublishAsync(QueueNames.ImageCleanup, new OldImageCleanupRequested(oldAvatar), cancellationToken);
        }

        return avatarUrl;
    }
}