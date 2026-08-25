namespace VidiVideo.Application.ContentReports;

public sealed record ContentReportStatsDto(
    int Pending,
    int Resolved,
    int Rejected);