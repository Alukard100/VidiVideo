using VidiVideo.Application.Common;

namespace VidiVideo.Application.ContentReports;

public sealed record GetContentReportsQuery : PagedRequest, IQuery<PagedResult<ContentReportDto>>;
