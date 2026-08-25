using VidiVideo.Domain.Enums;

namespace VidiVideo.Application.ContentReports;

public sealed record ContentReportItemDto(
    Guid ReportId,
    Guid ReporterId,
    string ReporterName,
    string Reason,
    ReportStatus Status,
    DateTime CreatedAtUtc);