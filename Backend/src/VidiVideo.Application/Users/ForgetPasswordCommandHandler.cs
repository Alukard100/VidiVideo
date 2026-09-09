using System.Security.Cryptography;
using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;

namespace VidiVideo.Application.Users;

public sealed class ForgetPasswordCommandHandler : ICommandHandler<ForgetPasswordCommand, bool>
{
    private readonly IUserRepository _userRepository;
    private readonly IPasswordHasher _passwordHasher;
    private readonly IEmailSender _emailSender;
    private readonly IUnitOfWork _unitOfWork;
    public ForgetPasswordCommandHandler(IUserRepository userRepository, IPasswordHasher passwordHasher, IEmailSender emailSender, IUnitOfWork unitOfWork)
    {
        _userRepository = userRepository;
        _passwordHasher = passwordHasher;
        _emailSender = emailSender;
        _unitOfWork = unitOfWork;
    }
    public async Task<bool> HandleAsync(ForgetPasswordCommand command, CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(command.Email)) throw new ValidationException("Email is required");

        var email = command.Email.Trim();

        var user = await _userRepository.GetByEmailAsync(email);

        if (user is null) return true;

        var code = RandomNumberGenerator.GetInt32(100000, 1000000).ToString();

        var codeHash = _passwordHasher.Hash(code);
        var expiresAtUtc = DateTime.UtcNow.AddMinutes(10);

        user.SetPasswordResetCode(codeHash, expiresAtUtc);

        await _unitOfWork.SaveChangesAsync(cancellationToken);

        await _emailSender.SendPasswordResetCodeAsync(user.Email, code, cancellationToken);

        return true;
    }
}
