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
        private readonly IVideoAccessService _videoAccessService;

        public RecordVideoViewCommandHandler(
            IVideoViewRepository repo,
            IVideoRepository videoRepo,
            IUserRepository userRepo,
            IUnitOfWork unitOfWork,
            ICurrentUser currentUser,
            IVideoAccessService videoAccessService)
        {
            _repo = repo;
            _videoRepo = videoRepo;
            _userRepo = userRepo;
            _unitOfWork = unitOfWork;
            _currentUser = currentUser;
            _videoAccessService = videoAccessService;
        }
        public async Task<Guid> HandleAsync(RecordVideoViewCommand command, CancellationToken cancellationToken)
        {
            var video = await _videoRepo.GetVideoByIdAsync(command.VideoId) ?? throw new NotFoundException("Video not found");

            var userId = _currentUser.UserId ?? throw new UnauthorizedException("Must be logged in");
            if (!await _userRepo.ExistsByIdAsync(userId))
                throw new NotFoundException("User not found");

            var access = await _videoAccessService.GetAccessAsync(userId, video, cancellationToken);
            if (!access.IsVisible) throw new NotFoundException("Video doesn't exist can't record view");
            if (access.IsLocked) throw new ForbiddenException("An active subscription is required to view this video");

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
