using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;

namespace VidiVideo.Application.ContentReports;

public sealed class GetReportsByStatusQueryHandler
    : IQueryHandler<
        GetReportsByStatusQuery,
        PagedResult<ContentReportDto>>
{
    private readonly IContentReportRepository _repo;

    public GetReportsByStatusQueryHandler(
        IContentReportRepository repo)
    {
        _repo = repo;
    }

    public async Task<PagedResult<ContentReportDto>> HandleAsync(
        GetReportsByStatusQuery query,
        CancellationToken cancellationToken)
    {
        var reports = await _repo.GetByStatusAsync(
            query.Status,
            query.Page,
            query.PageSize,
            cancellationToken);

        var total = await _repo.CountByStatusAsync(
            query.Status,
            cancellationToken);

        var items = reports
            .Select(r => new ContentReportDto(
                r.Id,
                r.ReporterId,
                r.VideoId,
                r.CommentId,
                r.Reason,
                r.Status,
                r.ReviewedById,
                r.ReviewedAtUtc,
                r.ResolutionNote))
            .ToList();

        return new PagedResult<ContentReportDto>(
            items,
            query.Page,
            query.PageSize,
            total);
    }
}