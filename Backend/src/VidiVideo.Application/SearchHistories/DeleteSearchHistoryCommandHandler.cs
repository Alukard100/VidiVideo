using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;

namespace VidiVideo.Application.SearchHistories
{
    public sealed class DeleteSearchHistoryCommandHandler : ICommandHandler<DeleteSearchHistoryCommand, bool>
    {
        private readonly ISearchHistoryRepository _repo;
        private readonly IUnitOfWork _unitOfWork;

        public DeleteSearchHistoryCommandHandler(ISearchHistoryRepository repo, IUnitOfWork unitOfWork)
        {
            _repo = repo;
            _unitOfWork = unitOfWork;
        }

        public async Task<bool> HandleAsync(DeleteSearchHistoryCommand command, CancellationToken cancellationToken)
        {
            var entity = await _repo.GetByIdAsync(command.Id);

            if (entity is null)
                return false;

            await _repo.DeleteAsync(command.Id);

            await _unitOfWork.SaveChangesAsync(cancellationToken);

            return true;
        }
    }
}
