using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Domain.Entities;

namespace VidiVideo.Application.SearchHistories
{
    public sealed class CreateSearchHistoryCommandHandler : ICommandHandler<CreateSearchHistoryCommand, Guid>
    {
        private readonly ISearchHistoryRepository _repo;
        private readonly IUnitOfWork _unitOfWork;

        public CreateSearchHistoryCommandHandler(ISearchHistoryRepository repo, IUnitOfWork unitOfWork)
        {
            _repo = repo;
            _unitOfWork = unitOfWork;
        }

        public async Task<Guid> HandleAsync(CreateSearchHistoryCommand command, CancellationToken cancellationToken)
        {
            var history = new SearchHistory(command.UserId, command.Query);

            await _repo.AddAsync(history);

            await _unitOfWork.SaveChangesAsync(cancellationToken);

            return history.Id;

        }
    }
}
