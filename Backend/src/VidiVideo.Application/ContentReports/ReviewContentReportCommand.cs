using VidiVideo.Application.Common;
using VidiVideo.Domain.Enums;

namespace VidiVideo.Application.ContentReports;

public sealed record ReviewContentReportCommand(
    Guid ReportId,
    string ResolutionNote,
    ReportStatus Status)
    : ICommand<Guid>;
