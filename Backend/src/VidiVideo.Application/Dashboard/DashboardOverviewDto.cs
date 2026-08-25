namespace VidiVideo.Application.Dashboard;

public sealed record DashboardOverviewDto
    (int ActiveAccounts,
    int TotalVideos,
    int TotalSubscriberVideos,
    int ActiveSubscribers,
    decimal TotalRevenue,
    int TotalTransactions,
    int TotalReports,
    int PendingReports,
    decimal VideoCompletionRate,
    List<DashboardRevenuePointDto> RevenueTrend);
