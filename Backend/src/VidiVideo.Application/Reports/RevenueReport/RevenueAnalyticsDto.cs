namespace VidiVideo.Application.Reports.RevenueReport;

public sealed record RevenueAnalyticsDto(
    DateTime? From,
    decimal TotalTransactionValue,
    decimal TotalRevenue,
    int TotalPayments,
    int TotalActiveSubscriptions,
    List<RevenueAnalyticsRow> Rows
    );
