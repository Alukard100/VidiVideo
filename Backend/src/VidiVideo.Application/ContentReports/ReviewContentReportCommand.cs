using VidiVideo.Application.Common;
using VidiVideo.Domain.Enums;

namespace VidiVideo.Application.ContentReports;

public sealed record ReviewContentReportCommand(
    Guid ContentId,
    string ContentType,
    string ResolutionNote,
    ReportStatus Status)
    : ICommand<bool>;