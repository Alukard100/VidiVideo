namespace VidiVideo.Application.ContentReports;

public sealed record ContentReportDetailDto(
    Guid ContentId,
    string ContentType,
    Guid CreatorId,
    string CreatorName,
    string ContentPreview,
    string? VideoStreamUrl,
    bool IsDeleted,
    IReadOnlyList<ContentReportItemDto> Reports);