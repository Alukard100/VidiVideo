using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;
using VidiVideo.Domain.Constants;
using VidiVideo.Domain.Entities;

namespace VidiVideo.Application.Users.Administrative;

public sealed class CreateStaffCommandHandler : ICommandHandler<CreateStaffCommand, Guid>
{
    private readonly IUserRepository _userRepository;
    private readonly IPasswordHasher _passwordHasher;
    private readonly ICurrentUser _currentUser;
    public CreateStaffCommandHandler(IUserRepository userRepository, IPasswordHasher passwordHasher, ICurrentUser currentUser)
    {
        _userRepository = userRepository;
        _passwordHasher = passwordHasher;
        _currentUser = currentUser;
    }

    public async Task<Guid> HandleAsync(CreateStaffCommand command, CancellationToken cancellationToken)
    {
        if (_currentUser.IsInRole(AppRoles.Moderator) || _currentUser.IsInRole(AppRoles.User))
            throw new UnauthorizedException("Not allowed");

        if (_currentUser.IsInRole(AppRoles.Admin) && (command.Role == AppRoles.Admin || command.Role == AppRoles.SuperAdmin))
            throw new UnauthorizedException("Not allowed");

        if (command.Role != AppRoles.Admin && command.Role != AppRoles.Moderator)
            throw new ValidationException("Invalid staff role");


        if (string.IsNullOrWhiteSpace(command.UserName) || command.UserName.Length < 5)
        {
            throw new ValidationException(
                "Username mustn't be empty or shorter than 5 characters");
        }

        if (string.IsNullOrWhiteSpace(command.DisplayName))
        {
            throw new ValidationException(
                "Please add a display name");
        }

        PasswordValidator.Validate(command.Password);

        if (await _userRepository.ExistsByEmailAsync(command.Email))
        {
            throw new ConflictException(
                "User with this email already exists.");
        }

        if (await _userRepository.ExistsByUserNameAsync(command.UserName))
        {
            throw new ConflictException(
                "User with this username already exists. ");
        }

        var hashedPassword = _passwordHasher.Hash(command.Password);

        var user = new AppUser(command.UserName, command.Email, hashedPassword, command.DisplayName, command.Role);

        await _userRepository.AddAsync(user);

        return user.Id;
    }
}
