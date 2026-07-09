using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;

namespace VidiVideo.Application.SearchHistories
{
    public sealed class GetSearchHistoryQueryHandler : IQueryHandler<GetSearchHistoryQuery, PagedResult<SearchHistoryDto>>
    {
        private readonly ISearchHistoryRepository _repo;
        public async Task<PagedResult<SearchHistoryDto>> HandleAsync(GetSearchHistoryQuery query, CancellationToken cancellationToken)
        {
            var count = await _repo.CountAsync(query.UserId);

            var history = await _repo.GetUserHistoryAsync(query.UserId, query.Page, query.PageSize);

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
