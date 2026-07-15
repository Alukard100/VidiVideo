using VidiVideo.Application.Abstractions;
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
        private readonly ICurrentUser _currentUser;

        public FollowCommandHandler(IFollowersRepository repo, IUnitOfWork unitOfWork, IUserRepository userRepository, INotificationRepository notificationRepository, ICurrentUser currentUser)
        {
            _repo = repo;
            _unitOfWork = unitOfWork;
            _userRepository = userRepository;
            _notificationRepository = notificationRepository;
            _currentUser = currentUser;
        }

        public async Task<bool> HandleAsync(FollowCommand command, CancellationToken cancellationToken)
        {
            var follower = _currentUser.UserId ?? throw new UnauthorizedException("Not logged in");

            if (!await _userRepository.BothUsersExistsById(follower, command.Creator))
                throw new NotFoundException("User doesn't exist");

            var follow = await _repo.CheckExistingAsync(follower, command.Creator);

            if (follow is null)
            {
                await _repo.FollowAsync(new Follow(follower, command.Creator));

                var currentUser = await _userRepository.GetByIdAsync(follower);
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
