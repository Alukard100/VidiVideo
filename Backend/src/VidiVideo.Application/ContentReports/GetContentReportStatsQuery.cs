using VidiVideo.Application.Common;

namespace VidiVideo.Application.ContentReports;

public sealed record GetContentReportStatsQuery
    : IQuery<ContentReportStatsDto>;