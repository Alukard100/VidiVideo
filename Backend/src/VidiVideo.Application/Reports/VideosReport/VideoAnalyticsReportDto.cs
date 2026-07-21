namespace VidiVideo.Application.Reports.VideosReport;

public sealed record VideoAnalyticsReportDto(
    DateTime? From,
    int TotalVideos,
    int PublishedVideos,
    int PublicVideos,
    int SubscriberVideos,
    int TotalViews,
    int TotalLikes,
    int TotalComments,
    List<VideoAnalyticsRow> Rows);

