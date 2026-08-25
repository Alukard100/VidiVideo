using VidiVideo.Application.Common;

namespace VidiVideo.Application.ContentReports;

public sealed record RemoveReportedContentCommand(
    Guid ContentId,
    string ContentType)
    : ICommand<bool>;
