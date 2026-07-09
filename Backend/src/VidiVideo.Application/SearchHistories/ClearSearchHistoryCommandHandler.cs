using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;

namespace VidiVideo.Application.SearchHistories
{
    public sealed class ClearSearchHistoryCommandHandler : ICommandHandler<ClearSearchHistoryCommand, bool>
    {
        private readonly ISearchHistoryRepository _repo;
        private readonly IUnitOfWork _unitOfWork;

        public ClearSearchHistoryCommandHandler(ISearchHistoryRepository repo, IUnitOfWork unitOfWork)
        {
            _repo = repo;
            _unitOfWork = unitOfWork;
        }

        public async Task<bool> HandleAsync(ClearSearchHistoryCommand command, CancellationToken cancellationToken)
        {
            await _repo.ClearAsync(command.Id);

            await _unitOfWork.SaveChangesAsync(cancellationToken);

            return true;
        }
    }
}
