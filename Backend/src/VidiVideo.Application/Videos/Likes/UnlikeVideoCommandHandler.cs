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
        public UnlikeVideoCommandHandler(ILikeRepository repo, IUnitOfWork unitOfWork, ICurrentUser currentUser)
        {
            _repo = repo;
            _unitOfWork = unitOfWork;
            _currentUser = currentUser;
        }

        public async Task<bool> HandleAsync(UnlikeVideoCommand command, CancellationToken cancellationToken)
        {
            var userId = _currentUser.UserId ?? throw new UnauthorizedException("Must be logged in");
            if (await _repo.IsLikedByCurrentUser(command.VideoId, userId))
            {
                await _repo.UnlikeVideoAsync(command.VideoId, userId);
                await _unitOfWork.SaveChangesAsync();
                return true;
            }

            return false;
        }
    }
}
