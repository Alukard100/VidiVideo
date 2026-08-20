using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;

namespace VidiVideo.Application.Users;

public sealed class ChangePasswordCommandHandler : ICommandHandler<ChangePasswordCommand, bool>
{
    private readonly IPasswordHasher _passwordHasher;
    private readonly ICurrentUser _currentUser;
    private readonly IUserRepository _userRepo;
    private readonly IUnitOfWork _unitOfWork;

    public ChangePasswordCommandHandler(IPasswordHasher passwordHasher, ICurrentUser currentUser, IUserRepository userRepo, IUnitOfWork unitOfWork)
    {
        _passwordHasher = passwordHasher;
        _currentUser = currentUser;
        _userRepo = userRepo;
        _unitOfWork = unitOfWork;
    }
    public async Task<bool> HandleAsync(ChangePasswordCommand command, CancellationToken cancellationToken)
    {
        var userId = _currentUser.UserId ?? throw new UnauthorizedException("Must be logged in");

        var user = await _userRepo.GetProfileByIdAsync(userId) ?? throw new NotFoundException("Invalid");

        if (!_passwordHasher.Verify(command.OldPassword, user.PasswordHash))
        {
            throw new ValidationException(
                "Invalid");
        }

        if (_passwordHasher.Verify(
            command.NewPassword,
            user.PasswordHash))
        {
            throw new ValidationException(
                "New password must be different from the current password.");
        }

        PasswordValidator.Validate(command.NewPassword);

        var newHash = _passwordHasher.Hash(command.NewPassword);

        user.UpdatePassword(newHash);

        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return true;

    }
}
