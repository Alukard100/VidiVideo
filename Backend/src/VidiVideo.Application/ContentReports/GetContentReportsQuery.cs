using VidiVideo.Application.Common;
using VidiVideo.Domain.Enums;

namespace VidiVideo.Application.ContentReports;

public sealed record GetContentReportsQuery
    : PagedRequest,
      IQuery<PagedResult<ContentReportSummaryDto>>
{
    public ReportStatus? Status { get; init; }
}