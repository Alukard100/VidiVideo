using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;

namespace VidiVideo.Application.SearchHistories
{
    public sealed class GetSearchHistoryQueryHandler : IQueryHandler<GetSearchHistoryQuery, PagedResult<SearchHistoryDto>>
    {
        private readonly ISearchHistoryRepository _repo;
        private readonly ICurrentUser _currentUser;
        public GetSearchHistoryQueryHandler(ISearchHistoryRepository repo, ICurrentUser currentUser)
        {
            _repo = repo;
            _currentUser = currentUser;
        }

        public async Task<PagedResult<SearchHistoryDto>> HandleAsync(GetSearchHistoryQuery query, CancellationToken cancellationToken)
        {
            var userId = _currentUser.UserId ?? throw new UnauthorizedException("Must be logged in");

            var count = await _repo.CountAsync(userId);

            var history = await _repo.GetUserHistoryAsync(userId, query.Page, query.PageSize);

            var items = history.Select(x => new SearchHistoryDto(
                x.Id,
                x.UserId,
                x.Query,
                x.CreatedAtUtc))
            .ToList();

            return new PagedResult<SearchHistoryDto>(items, query.Page, query.PageSize, count);
        }
    }
}
