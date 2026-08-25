using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;
using VidiVideo.Domain.Constants;

namespace VidiVideo.Application.Users.Administrative;

public sealed class UpdateUserStatusCommandHandler
    : ICommandHandler<
        UpdateUserStatusCommand,
        bool>
{
    private readonly IUserRepository _userRepository;
    private readonly IUnitOfWork _unitOfWork;

    public UpdateUserStatusCommandHandler(
        IUserRepository userRepository,
        IUnitOfWork unitOfWork)
    {
        _userRepository = userRepository;
        _unitOfWork = unitOfWork;
    }

    public async Task<bool> HandleAsync(
        UpdateUserStatusCommand command,
        CancellationToken cancellationToken)
    {
        var user =
            await _userRepository.GetByIdAsync(
                command.UserId)
            ?? throw new NotFoundException(
                "User doesn't exist.");

        if (user.Role != AppRoles.User)
        {
            throw new ValidationException(
                "Staff accounts cannot be modified from user management.");
        }

        user.ChangeStatus(command.Status);

        await _unitOfWork.SaveChangesAsync(
            cancellationToken);

        return true;
    }
}
