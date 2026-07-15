using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;
using VidiVideo.Domain.Entities;

namespace VidiVideo.Application.VideoViews
{
    public sealed class RecordVideoViewCommandHandler : ICommandHandler<RecordVideoViewCommand, Guid>
    {
        private readonly IVideoViewRepository _repo;
        private readonly IVideoRepository _videoRepo;
        private readonly IUserRepository _userRepo;
        private readonly IUnitOfWork _unitOfWork;
        private readonly ICurrentUser _currentUser;

        public RecordVideoViewCommandHandler(
            IVideoViewRepository repo,
            IVideoRepository videoRepo,
            IUserRepository userRepo,
            IUnitOfWork unitOfWork,
            ICurrentUser currentUser)
        {
            _repo = repo;
            _videoRepo = videoRepo;
            _userRepo = userRepo;
            _unitOfWork = unitOfWork;
            _currentUser = currentUser;
        }
        public async Task<Guid> HandleAsync(RecordVideoViewCommand command, CancellationToken cancellationToken)
        {
            if (!await _videoRepo.ExistsByIdAsync(command.VideoId))
                throw new NotFoundException("Video not found");

            var userId = _currentUser.UserId ?? throw new UnauthorizedException("Must be logged in");

            if (!await _userRepo.ExistsByIdAsync(userId))
                throw new NotFoundException("User not found");

            var existing =
                await _repo.GetByUserAndVideoAsync(
                    userId, command.VideoId);

            if (existing is null)
            {
                existing = new VideoView(userId, command.VideoId, command.WatchDurationSeconds, command.CompletionRate);
                await _repo.CreateAsync(existing);
            }
            else
            {
                existing.UpdateTimes(command.WatchDurationSeconds, command.CompletionRate);
            }

            await _unitOfWork.SaveChangesAsync(cancellationToken);

            return existing.Id;
        }
    }
}
