using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;
using VidiVideo.Domain.Entities;

namespace VidiVideo.Application.SearchHistories
{
    public sealed class CreateSearchHistoryCommandHandler : ICommandHandler<CreateSearchHistoryCommand, Guid>
    {
        private readonly ISearchHistoryRepository _repo;
        private readonly IUnitOfWork _unitOfWork;
        private readonly ICurrentUser _currentUser;

        public CreateSearchHistoryCommandHandler(ISearchHistoryRepository repo, IUnitOfWork unitOfWork, ICurrentUser currentUser)
        {
            _repo = repo;
            _unitOfWork = unitOfWork;
            _currentUser = currentUser;
        }

        public async Task<Guid> HandleAsync(CreateSearchHistoryCommand command, CancellationToken cancellationToken)
        {
            var userId = _currentUser.UserId ?? throw new UnauthorizedException("Must be logged in");

            var history = new SearchHistory(userId, command.Query);

            await _repo.AddAsync(history);

            await _unitOfWork.SaveChangesAsync(cancellationToken);

            return history.Id;

        }
    }
}
