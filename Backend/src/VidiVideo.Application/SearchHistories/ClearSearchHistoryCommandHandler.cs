using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;

namespace VidiVideo.Application.SearchHistories
{
    public sealed class ClearSearchHistoryCommandHandler : ICommandHandler<ClearSearchHistoryCommand, bool>
    {
        private readonly ISearchHistoryRepository _repo;
        private readonly IUnitOfWork _unitOfWork;
        private readonly ICurrentUser _currentUser;

        public ClearSearchHistoryCommandHandler(ISearchHistoryRepository repo, IUnitOfWork unitOfWork, ICurrentUser currentUser)
        {
            _repo = repo;
            _unitOfWork = unitOfWork;
            _currentUser = currentUser;
        }

        public async Task<bool> HandleAsync(ClearSearchHistoryCommand command, CancellationToken cancellationToken)
        {
            var userId = _currentUser.UserId ?? throw new UnauthorizedException("Must be logged in");

            await _repo.ClearAsync(userId);

            await _unitOfWork.SaveChangesAsync(cancellationToken);

            return true;
        }
    }
}
