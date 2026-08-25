using VidiVideo.Application.Common;

namespace VidiVideo.Application.ContentReports;

public sealed record GetContentReportDetailQuery(
    Guid ContentId,
    bool IsVideo)
    : IQuery<ContentReportDetailDto>;