
using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;
using VidiVideo.Domain.Entities;

namespace VidiVideo.Application.Users
{
    public sealed class RegisterUserCommandHandler : ICommandHandler<RegisterUserCommand, Guid>
    {
        private readonly IUserRepository _userRepository;
        private readonly IPasswordHasher _passwordHasher;

        public RegisterUserCommandHandler(IUserRepository userRepository, IPasswordHasher passwordHasher)
        {
            _userRepository = userRepository;
            _passwordHasher = passwordHasher;
        }

        public async Task<Guid> HandleAsync(RegisterUserCommand command, CancellationToken cancellationToken)
        {
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

            var hashedPassword = _passwordHasher.Hash(command.Password);

            var user = new AppUser(command.UserName, command.Email, hashedPassword, command.DisplayName);

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

            await _userRepository.AddAsync(user);

            return user.Id;
        }
    }
}
