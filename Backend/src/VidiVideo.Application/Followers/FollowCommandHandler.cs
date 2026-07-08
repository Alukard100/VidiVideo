using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;
using VidiVideo.Domain.Entities;
using VidiVideo.Domain.Enums;

namespace VidiVideo.Application.Followers
{
    public sealed class FollowCommandHandler : ICommandHandler<FollowCommand, bool>
    {
        private readonly IFollowersRepository _repo;
        private readonly IUserRepository _userRepository;
        private readonly INotificationRepository _notificationRepository;
        private readonly IUnitOfWork _unitOfWork;

        public FollowCommandHandler(IFollowersRepository repo, IUnitOfWork unitOfWork, IUserRepository userRepository, INotificationRepository notificationRepository)
        {
            _repo = repo;
            _unitOfWork = unitOfWork;
            _userRepository = userRepository;
            _notificationRepository = notificationRepository;
        }

        public async Task<bool> HandleAsync(FollowCommand command, CancellationToken cancellationToken)
        {
            if (await _userRepository.BothUsersExistsById(command.Follower, command.Creator))
                throw new NotFoundException("User doesn't exist");

            var follow = await _repo.CheckExistingAsync(command.Follower, command.Creator);

            if (follow is null)
            {
                await _repo.FollowAsync(new Follow(command.Follower, command.Creator));

                var currentUser = await _userRepository.GetByIdAsync(command.Follower);
                var notification = new Notification(command.Creator, "New follower", $"{currentUser.DisplayName} started following you", NotificationType.Follow);
                await _notificationRepository.CreateAsync(notification);
            }
            else if (follow.IsDeleted)
            {
                follow.ReturnFollow();
            }
            else
            {
                throw new ConflictException("Already following");
            }

            await _unitOfWork.SaveChangesAsync(cancellationToken);
            return true;

        }
    }
}
