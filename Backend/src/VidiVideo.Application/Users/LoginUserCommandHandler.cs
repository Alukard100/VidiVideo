using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;

namespace VidiVideo.Application.Users
{
    public sealed class LoginUserCommandHandler : ICommandHandler<LoginUserCommand, LoginUserResponse>
    {
        private readonly IUserRepository _userRepository;
        private readonly IPasswordHasher _passwordHasher;
        private readonly ITokenGenerator _tokenGenerator;

        public LoginUserCommandHandler(IUserRepository userRepository, IPasswordHasher passwordHasher, ITokenGenerator tokenGenerator)
        {
            _userRepository = userRepository;
            _passwordHasher = passwordHasher;
            _tokenGenerator = tokenGenerator;
        }

        public async Task<LoginUserResponse> HandleAsync(LoginUserCommand command, CancellationToken cancellationToken)
        {
            var user = await _userRepository.GetByUserNameAsync(command.UserName)
                        ?? throw new NotFoundException("Invalid username or password");

            if (!_passwordHasher.Verify(command.Password, user.PasswordHash))
            {
                throw new UnauthorizedException(
                    "Invalid username or password");
            }

            var token = _tokenGenerator.GenerateToken(user);

            return new LoginUserResponse(
                user.Id, user.UserName, user.Role, token);
        }
    }
}
