using VidiVideo.Domain.Enums;

namespace VidiVideo.Application.ContentReports;

public sealed record ContentReportDto(
    Guid Id,
    Guid ReporterId,
    Guid? VideoId,
    Guid? CommentId,
    string Reason,
    ReportStatus Status,
    Guid? ReviewedById,
    DateTime? ReviewedAtUtc,
    string? ResolutionNote);
