using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;

namespace VidiVideo.Application.ContentReports
{
    public sealed class GetContentReportsQueryHandler : IQueryHandler<GetContentReportsQuery, PagedResult<ContentReportDto>>
    {
        private readonly IContentReportRepository _repo;
        public GetContentReportsQueryHandler(IContentReportRepository repo)
        {
            _repo = repo;
        }

        public async Task<PagedResult<ContentReportDto>> HandleAsync(GetContentReportsQuery query, CancellationToken cancellationToken)
        {
            var reports = await _repo.GetPagedAsync(query.Page, query.PageSize);

            var items = reports.Select(c => new ContentReportDto(c.Id, c.ReporterId, c.VideoId, c.CommentId, c.Reason, c.Status, c.ReviewedById, c.ReviewedAtUtc, c.ResolutionNote)).ToList();

            var total = await _repo.CountAsync();

            return new PagedResult<ContentReportDto>(
                items,
                total,
                query.Page,
                query.PageSize);

        }
    }
}
