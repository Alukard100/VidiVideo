using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;

namespace VidiVideo.Application.ContentReports;

public sealed class GetContentReportStatsQueryHandler
    : IQueryHandler<
        GetContentReportStatsQuery,
        ContentReportStatsDto>
{
    private readonly IContentReportRepository _repo;

    public GetContentReportStatsQueryHandler(
        IContentReportRepository repo)
    {
        _repo = repo;
    }

    public Task<ContentReportStatsDto> HandleAsync(
        GetContentReportStatsQuery query,
        CancellationToken cancellationToken)
    {
        return _repo.GetStatsAsync(cancellationToken);
    }
}