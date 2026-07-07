using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;

namespace VidiVideo.Application.Videos.Likes
{
    public sealed class UnlikeVideoCommandHandler : ICommandHandler<UnlikeVideoCommand, bool>
    {
        private readonly ILikeRepository _repo;
        private readonly IUnitOfWork _unitOfWork;
        public UnlikeVideoCommandHandler(ILikeRepository repo, IUnitOfWork unitOfWork)
        {
            _repo = repo;
            _unitOfWork = unitOfWork;
        }

        public async Task<bool> HandleAsync(UnlikeVideoCommand command, CancellationToken cancellationToken)
        {
            if (await _repo.IsLikedByCurrentUser(command.videoId, command.userId))
            {
                await _repo.UnlikeVideoAsync(command.videoId, command.userId);
                await _unitOfWork.SaveChangesAsync();
                return true;
            }

            return false;
        }
    }
}
