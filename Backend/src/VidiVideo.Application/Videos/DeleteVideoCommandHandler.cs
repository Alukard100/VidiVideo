using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;
using VidiVideo.Domain.Constants;

namespace VidiVideo.Application.Videos
{
    public sealed class DeleteVideoCommandHandler : ICommandHandler<DeleteVideoCommand, bool>
    {
        private readonly IVideoRepository _repo;
        private readonly IUnitOfWork _unitOfWork;
        private readonly ICurrentUser _currentUser;

        public DeleteVideoCommandHandler(IVideoRepository repo, IUnitOfWork unitOfWork, ICurrentUser currentUser)
        {
            _repo = repo;
            _unitOfWork = unitOfWork;
            _currentUser = currentUser;
        }

        public async Task<bool> HandleAsync(DeleteVideoCommand command, CancellationToken cancellationToken)
        {
            if (!await _repo.ExistsByIdAsync(command.Id, cancellationToken))
                throw new NotFoundException("Video doesn't exist");

            var creatorId = _currentUser.UserId ?? throw new UnauthorizedException("Must be logged in");

            if (!_currentUser.IsInRole(AppRoles.Admin))
                if (!await _repo.CheckOwnershipAsync(creatorId, command.Id, cancellationToken))
                    throw new UnauthorizedException("You are not the owner of this video");

            await _repo.DeleteVideoAsync(command.Id, cancellationToken);

            await _unitOfWork.SaveChangesAsync(cancellationToken);

            return true;
        }
    }
}
