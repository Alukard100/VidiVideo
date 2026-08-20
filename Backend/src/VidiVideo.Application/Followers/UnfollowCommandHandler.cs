using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;

namespace VidiVideo.Application.Followers
{
    public sealed class UnfollowCommandHandler : ICommandHandler<UnfollowCommand, bool>
    {
        private readonly IFollowersRepository _repo;
        private readonly IUserRepository _userRepository;
        private readonly IUnitOfWork _unitOfWork;
        private readonly ICurrentUser _currentUser;

        public UnfollowCommandHandler(IFollowersRepository repo, IUserRepository userRepository, IUnitOfWork unitOfWork, ICurrentUser currentUser)
        {
            _repo = repo;
            _userRepository = userRepository;
            _unitOfWork = unitOfWork;
            _currentUser = currentUser;
        }

        public async Task<bool> HandleAsync(UnfollowCommand command, CancellationToken cancellationToken)
        {
            var follower = _currentUser.UserId ?? throw new UnauthorizedException("Not logged in");

            if (!await _userRepository.BothUsersExistsById(follower, command.Creator))
                throw new NotFoundException("Users don't exist");

            var follow = await _repo.CheckExistingAsync(follower, command.Creator);

            if (follow == null)
            {
                throw new ValidationException("Already not following");
            }
            else if (follow.IsDeleted)
            {
                throw new ValidationException("Already not following");
            }
            else
            {
                follow.RemoveFollow();
            }

            await _unitOfWork.SaveChangesAsync(cancellationToken);
            return true;
        }
    }
}
