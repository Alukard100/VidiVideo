namespace VidiVideo.Application.Reports.RevenueReport;

public sealed record RevenueAnalyticsRow(
    string Creator,
    int ActiveSubscribers,
    decimal Revenue,
    int CompletedPayments
    );
