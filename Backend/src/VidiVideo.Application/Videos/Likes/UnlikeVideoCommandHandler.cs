using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;

namespace VidiVideo.Application.Videos.Likes
{
    public sealed class UnlikeVideoCommandHandler : ICommandHandler<UnlikeVideoCommand, bool>
    {
        private readonly ILikeRepository _repo;
        private readonly IUnitOfWork _unitOfWork;
        private readonly ICurrentUser _currentUser;
        private readonly IVideoRepository _videoRepository;
        private readonly IVideoAccessService _videoAccessService;
        public UnlikeVideoCommandHandler(ILikeRepository repo, IUnitOfWork unitOfWork, ICurrentUser currentUser, IVideoAccessService videoAccessService, IVideoRepository videoRepository)
        {
            _repo = repo;
            _unitOfWork = unitOfWork;
            _currentUser = currentUser;
            _videoAccessService = videoAccessService;
            _videoRepository = videoRepository;
        }

        public async Task<bool> HandleAsync(UnlikeVideoCommand command, CancellationToken cancellationToken)
        {
            var userId = _currentUser.UserId ?? throw new UnauthorizedException("Must be logged in");

            var video = await _videoRepository.GetVideoByIdAsync(command.VideoId, cancellationToken) ?? throw new NotFoundException("Video doesn't exist");

            var access = await _videoAccessService.GetAccessAsync(userId, video, cancellationToken);
            if (!access.IsVisible) throw new NotFoundException("Video doesn't exist");
            if (access.IsLocked) throw new ForbiddenException("An active subscription is required to access this video");


            if (await _repo.IsLikedByCurrentUser(command.VideoId, userId))
            {
                await _repo.UnlikeVideoAsync(command.VideoId, userId);
                await _unitOfWork.SaveChangesAsync(cancellationToken);
                return true;
            }

            return false;
        }
    }
}
