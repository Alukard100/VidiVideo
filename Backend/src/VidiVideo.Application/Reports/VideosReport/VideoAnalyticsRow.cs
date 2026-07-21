namespace VidiVideo.Application.Reports.VideosReport;

public sealed record VideoAnalyticsRow(
    string Caption,
    string Creator,
    int Views,
    int Likes,
    int Comments);
