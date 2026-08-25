using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;

namespace VidiVideo.Application.ContentReports
{
    public sealed class GetContentReportsQueryHandler : IQueryHandler<GetContentReportsQuery, PagedResult<ContentReportSummaryDto>>
    {
        private readonly IContentReportRepository _repo;
        public GetContentReportsQueryHandler(IContentReportRepository repo)
        {
            _repo = repo;
        }

        public async Task<PagedResult<ContentReportSummaryDto>> HandleAsync(GetContentReportsQuery query, CancellationToken cancellationToken)
        {
            var reports =
            await _repo.GetGroupedAsync(
                query.Status,
                query.Page,
                query.PageSize,
                cancellationToken);

            var total =
                await _repo.CountGroupedAsync(
                    query.Status,
                    cancellationToken);

            return new PagedResult<
                ContentReportSummaryDto>(
                    reports,
                    query.Page,
                    query.PageSize,
                    total);

        }
    }
}
