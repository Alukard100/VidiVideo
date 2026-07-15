using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;
using VidiVideo.Domain.Constants;

namespace VidiVideo.Application.Videos.Comments
{
    public sealed class UpdateCommentCommandHandler : ICommandHandler<UpdateCommentCommand, Guid>
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly ICommentRepository _repo;
        private readonly ICurrentUser _currentUser;
        public UpdateCommentCommandHandler(IUnitOfWork unitOfWork, ICommentRepository repo, ICurrentUser currentUser)
        {
            _unitOfWork = unitOfWork;
            _repo = repo;
            _currentUser = currentUser;
        }

        public async Task<Guid> HandleAsync(UpdateCommentCommand command, CancellationToken cancellationToken)
        {
            if (string.IsNullOrWhiteSpace(command.Content))
                throw new ValidationException("New comment can't be empty");

            var comment = await _repo.GetCommentByIdAsync(command.Id) ?? throw new NotFoundException("Comment doesn't exist");

            var creatorId = _currentUser.UserId ?? throw new UnauthorizedException("Must be logged in");

            if (!_currentUser.IsInRole(AppRoles.Admin))
                if (!await _repo.CheckOwnershipAsync(creatorId, command.Id))
                    throw new UnauthorizedException("This comment isn't yours");

            comment.UpdateComment(command.Content);

            await _unitOfWork.SaveChangesAsync();

            return command.Id;
        }
    }
}
