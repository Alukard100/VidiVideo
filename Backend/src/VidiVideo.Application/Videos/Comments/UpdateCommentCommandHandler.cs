using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;

namespace VidiVideo.Application.Videos.Comments
{
    public sealed class UpdateCommentCommandHandler : ICommandHandler<UpdateCommentCommand, Guid>
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly ICommentRepository _repo;
        public UpdateCommentCommandHandler(IUnitOfWork unitOfWork, ICommentRepository repo)
        {
            _unitOfWork = unitOfWork;
            _repo = repo;

        }

        public async Task<Guid> HandleAsync(UpdateCommentCommand command, CancellationToken cancellationToken)
        {
            if (string.IsNullOrWhiteSpace(command.content))
                throw new ValidationException("New comment can't be empty");

            var comment = await _repo.GetCommentByIdAsync(command.id) ?? throw new NotFoundException("Comment doesn't exist");

            comment.UpdateComment(command.content);

            await _unitOfWork.SaveChangesAsync();

            return command.id;
        }
    }
}
