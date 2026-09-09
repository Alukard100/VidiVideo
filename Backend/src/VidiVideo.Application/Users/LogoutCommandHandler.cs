using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;

namespace VidiVideo.Application.Users;

public sealed class LogoutCommandHandler : ICommandHandler<LogoutCommand, bool>
{
    private readonly ICurrentUser _currentUser;
    private readonly IUserRepository _userRepository;
    private readonly IUnitOfWork _unitOfWork;

    public LogoutCommandHandler(
        ICurrentUser currentUser,
        IUserRepository userRepository,
        IUnitOfWork unitOfWork)
    {
        _currentUser = currentUser;
        _userRepository = userRepository;
        _unitOfWork = unitOfWork;
    }

    public async Task<bool> HandleAsync(
        LogoutCommand command,
        CancellationToken cancellationToken)
    {
        var userId = _currentUser.UserId
            ?? throw new UnauthorizedException(
                "Must be logged in.");

        var user = await _userRepository.GetByIdAsync(
            userId)
            ?? throw new NotFoundException(
                "User doesn't exist.");

        user.RevokeTokens();

        await _unitOfWork.SaveChangesAsync(
            cancellationToken);

        return true;
    }
}
