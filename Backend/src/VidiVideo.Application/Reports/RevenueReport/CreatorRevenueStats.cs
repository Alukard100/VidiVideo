namespace VidiVideo.Application.Reports.RevenueReport;

public sealed record CreatorRevenueStats(
    string Creator,
    int ActiveSubscribers,
    decimal Revenue,
    int CompletedPayments
    );

