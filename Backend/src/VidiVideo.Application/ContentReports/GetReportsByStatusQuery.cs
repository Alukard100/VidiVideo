using VidiVideo.Application.Common;
using VidiVideo.Domain.Enums;

namespace VidiVideo.Application.ContentReports;

public sealed record GetReportsByStatusQuery
    : PagedRequest,
      IQuery<PagedResult<ContentReportDto>>
{
    public ReportStatus Status { get; init; }
}