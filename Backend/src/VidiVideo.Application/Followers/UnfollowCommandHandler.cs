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

        public UnfollowCommandHandler(IFollowersRepository repo, IUserRepository userRepository, IUnitOfWork unitOfWork)
        {
            _repo = repo;
            _userRepository = userRepository;
            _unitOfWork = unitOfWork;
        }

        public async Task<bool> HandleAsync(UnfollowCommand command, CancellationToken cancellationToken)
        {
            if (await _userRepository.BothUsersExistsById(command.Follower, command.Creator))
                throw new NotFoundException("Users don't exist");

            var follow = await _repo.CheckExistingAsync(command.Follower, command.Creator);

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
