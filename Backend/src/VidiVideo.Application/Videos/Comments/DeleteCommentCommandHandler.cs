using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;
using VidiVideo.Domain.Constants;

namespace VidiVideo.Application.Videos.Comments
{
    public sealed class DeleteCommentCommandHandler : ICommandHandler<DeleteCommentCommand, bool>
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly ICommentRepository _repo;
        private readonly ICurrentUser _currentUser;

        public DeleteCommentCommandHandler(IUnitOfWork unitOfWork, ICommentRepository repo, ICurrentUser currentUser)
        {
            _unitOfWork = unitOfWork;
            _repo = repo;
            _currentUser = currentUser;
        }

        public async Task<bool> HandleAsync(DeleteCommentCommand command, CancellationToken cancellationToken)
        {
            if (!await _repo.ExistsByIdAsync(command.Id))
                throw new NotFoundException("Comment doesn't exist");

            var creatorId = _currentUser.UserId ?? throw new UnauthorizedException("Must be logged in");

            if (!_currentUser.IsInRole(AppRoles.Admin))
                if (!await _repo.CheckOwnershipAsync(creatorId, command.Id))
                    throw new UnauthorizedException("You are not the owner of this comment");

            await _repo.DeleteCommentAsync(command.Id);

            await _unitOfWork.SaveChangesAsync(cancellationToken);

            return true;
        }
    }
}
