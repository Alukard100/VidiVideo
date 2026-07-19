using VidiVideo.Domain.Common;
using VidiVideo.Domain.Enums;

namespace VidiVideo.Domain.Entities;

public sealed class ContentReport : AuditableEntity
{
    public Guid ReporterId { get; set; }
    public AppUser Reporter { get; set; } = null!;
    public Guid? VideoId { get; set; }
    public Video? Video { get; set; }
    public Guid? CommentId { get; set; }
    public Comment? Comment { get; set; }
    public string Reason { get; set; } = string.Empty;
    public ReportStatus Status { get; set; } = ReportStatus.Pending;
    public Guid? ReviewedById { get; set; }
    public AppUser? ReviewedBy { get; set; }
    public DateTime? ReviewedAtUtc { get; set; }
    public string? ResolutionNote { get; set; }

    protected ContentReport() { }

    public ContentReport(Guid reporterId, Guid? videoId, Guid? commentId, string reason)
    {
        ReporterId = reporterId;
        VideoId = videoId;
        CommentId = commentId;
        Reason = reason;
    }

    public void Review(Guid reviewerId, string resolutionNote, ReportStatus reportStatus)
    {
        ReviewedById = reviewerId;
        ReviewedAtUtc = DateTime.UtcNow;
        ResolutionNote = resolutionNote;
        Status = reportStatus;
    }
}
