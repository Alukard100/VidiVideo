using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;

namespace VidiVideo.Application.Users;

public sealed class ResetPasswordCommandHandler : ICommandHandler<ResetPasswordCommand, bool>
{
    private readonly IUserRepository _userRepository;
    private readonly IPasswordHasher _passwordHasher;
    private readonly IUnitOfWork _unitOfWork;
    public ResetPasswordCommandHandler(IUserRepository userRepository, IPasswordHasher passwordHasher, IUnitOfWork unitOfWork)
    {
        _userRepository = userRepository;
        _passwordHasher = passwordHasher;
        _unitOfWork = unitOfWork;
    }
    public async Task<bool> HandleAsync(ResetPasswordCommand command, CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(command.Email)) throw new ValidationException("Email is required.");

        if (string.IsNullOrWhiteSpace(command.Code)) throw new ValidationException("Reset code is required");

        PasswordValidator.Validate(command.NewPassword);

        var user = await _userRepository.GetByEmailAsync(command.Email.Trim()) ?? throw new ValidationException("Invalid or expired rest code.");

        if (string.IsNullOrWhiteSpace(user.PasswordResetCodeHash) || !user.PasswordResetCodeExpiresAtUtc.HasValue) throw new ValidationException("Invalid or expired rest code.");

        if (user.PasswordResetCodeExpiresAtUtc <= DateTime.UtcNow)
        {
            user.ClearPasswordResetCode();
            await _unitOfWork.SaveChangesAsync(cancellationToken);
            throw new ValidationException("Invalid or expired reset code.");
        }

        if (!_passwordHasher.Verify(command.Code.Trim(), user.PasswordResetCodeHash)) throw new ValidationException("Invalid or expired reset code");

        if (_passwordHasher.Verify(command.NewPassword, user.PasswordHash)) throw new ValidationException("New password must be different from the current password.");

        var newPasswordHash = _passwordHasher.Hash(command.NewPassword);

        user.UpdatePassword(newPasswordHash);

        user.ClearPasswordResetCode();

        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return true;
    }
}
