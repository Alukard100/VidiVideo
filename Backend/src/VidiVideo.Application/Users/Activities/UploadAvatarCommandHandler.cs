using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;

public sealed class UploadAvatarCommandHandler
    : ICommandHandler<UploadAvatarCommand, string>
{
    private readonly IImageStorageService _imageStorage;
    private readonly IUserRepository _userRepository;
    private readonly ICurrentUser _currentUser;
    private readonly IUnitOfWork _unitOfWork;

    public UploadAvatarCommandHandler(
        IImageStorageService imageStorage,
        IUserRepository userRepository,
        ICurrentUser currentUser,
        IUnitOfWork unitOfWork)
    {
        _imageStorage = imageStorage;
        _userRepository = userRepository;
        _currentUser = currentUser;
        _unitOfWork = unitOfWork;
    }

    public async Task<string> HandleAsync(
        UploadAvatarCommand command,
        CancellationToken cancellationToken)
    {
        var userId = _currentUser.UserId
            ?? throw new UnauthorizedException("Must be logged in.");

        var user = await _userRepository.GetByIdAsync(userId)
            ?? throw new NotFoundException("User doesn't exist.");

        var avatarUrl = await _imageStorage.UploadAsync(
            command.ImageStream,
            command.FileName);

        user.UpdateAvatar(avatarUrl);

        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return avatarUrl;
    }
}