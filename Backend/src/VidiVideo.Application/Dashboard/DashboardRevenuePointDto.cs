namespace VidiVideo.Application.Dashboard;

public sealed record DashboardRevenuePointDto(
    int Year,
    int Month,
    decimal Revenue);