using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;

namespace VidiVideo.Application.SearchHistories
{
    public sealed class DeleteSearchHistoryCommandHandler : ICommandHandler<DeleteSearchHistoryCommand, bool>
    {
        private readonly ISearchHistoryRepository _repo;
        private readonly IUnitOfWork _unitOfWork;
        private readonly ICurrentUser _currentUser;

        public DeleteSearchHistoryCommandHandler(ISearchHistoryRepository repo, IUnitOfWork unitOfWork, ICurrentUser currentUser)
        {
            _repo = repo;
            _unitOfWork = unitOfWork;
            _currentUser = currentUser;
        }

        public async Task<bool> HandleAsync(DeleteSearchHistoryCommand command, CancellationToken cancellationToken)
        {
            var userId = _currentUser.UserId ?? throw new UnauthorizedException("Must be logged in.");

            var entity = await _repo.GetByIdAsync(command.Id);

            if (entity is null)
                return false;

            if (entity.UserId != userId) throw new ForbiddenException("You cannot delete another user's search history.");

            await _repo.DeleteAsync(command.Id);

            await _unitOfWork.SaveChangesAsync(cancellationToken);

            return true;
        }
    }
}
