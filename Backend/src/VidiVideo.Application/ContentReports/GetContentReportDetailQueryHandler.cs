using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;

namespace VidiVideo.Application.ContentReports;

public sealed class GetContentReportDetailQueryHandler
    : IQueryHandler<
        GetContentReportDetailQuery,
        ContentReportDetailDto>
{
    private readonly IContentReportRepository _repo;

    public GetContentReportDetailQueryHandler(
        IContentReportRepository repo)
    {
        _repo = repo;
    }

    public async Task<ContentReportDetailDto>
        HandleAsync(
            GetContentReportDetailQuery query,
            CancellationToken cancellationToken)
    {
        return await _repo
            .GetContentReportDetailAsync(
                query.ContentId,
                query.IsVideo,
                cancellationToken)
            ?? throw new NotFoundException(
                "Reported content doesn't exist.");
    }
}