using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;

namespace VidiVideo.Application.Videos.Comments
{
    public sealed class DeleteCommentCommandHandler : ICommandHandler<DeleteCommentCommand, bool>
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly ICommentRepository _repo;

        public DeleteCommentCommandHandler(IUnitOfWork unitOfWork, ICommentRepository repo)
        {
            _unitOfWork = unitOfWork;
            _repo = repo;
        }

        public async Task<bool> HandleAsync(DeleteCommentCommand command, CancellationToken cancellationToken)
        {
            if (await _repo.ExistsByIdAsync(command.Id))
                throw new NotFoundException("Comment doesn't exist");

            await _repo.DeleteCommentAsync(command.Id);

            await _unitOfWork.SaveChangesAsync();

            return true;
        }
    }
}
