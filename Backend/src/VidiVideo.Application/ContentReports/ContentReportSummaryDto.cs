using VidiVideo.Domain.Enums;

namespace VidiVideo.Application.ContentReports;

public sealed record ContentReportSummaryDto(
    Guid ContentId,
    string ContentType,
    Guid CreatorId,
    string CreatorName,
    string ContentPreview,
    int ReportCount,
    ReportStatus Status,
    DateTime LastReportedAtUtc);