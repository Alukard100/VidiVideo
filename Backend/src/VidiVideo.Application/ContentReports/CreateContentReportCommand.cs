using VidiVideo.Application.Common;

namespace VidiVideo.Application.ContentReports;

public sealed record CreateContentReportCommand(
    System.Guid? VideoId,
    System.Guid? CommentId,
    string Reason)
    : ICommand<System.Guid>;
