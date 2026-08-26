using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;

namespace VidiVideo.Application.Dashboard;

public sealed class GetDashboardOverviewQueryHandler : IQueryHandler<GetDashboardOverviewQuery, DashboardOverviewDto>
{
    private readonly IUserRepository _userRepo;
    private readonly IVideoRepository _videoRepo;
    private readonly IPaymentRepository _paymentRepo;
    private readonly IContentReportRepository _contentReportRepo;
    private readonly IVideoViewRepository _viewRepo;
    private readonly IPaymentSettings _paymentSettings;
    public GetDashboardOverviewQueryHandler(IUserRepository userRepo, IVideoRepository videoRepo, IPaymentRepository paymentRepo, IContentReportRepository contentReportRepo, IVideoViewRepository viewRepo, IPaymentSettings paymentSettings)
    {
        _userRepo = userRepo;
        _videoRepo = videoRepo;
        _paymentRepo = paymentRepo;
        _contentReportRepo = contentReportRepo;
        _viewRepo = viewRepo;
        _paymentSettings = paymentSettings;
    }

    public async Task<DashboardOverviewDto> HandleAsync(GetDashboardOverviewQuery query, CancellationToken cancellationToken)
    {
        var activeAccountsConunt = await _userRepo.CountFilteredUsersAsync(null, Domain.Enums.UserStatus.Active, cancellationToken);

        var videosCount = await _videoRepo.CountVideosFromAsync(null, cancellationToken);

        var subVideosCount = await _videoRepo.CountSubscriberAsync(null, cancellationToken);

        var subscriberCount = await _paymentRepo.TotalActiveSubsAsync(cancellationToken);

        var paymentsCount = await _paymentRepo.TotalPaymentsAsync(null, cancellationToken);

        var totalTransactionValue = await _paymentRepo.TotalRevenueAsync(null, cancellationToken);

        var totalRevenue = paymentsCount * _paymentSettings.PlatformFee;

        var totalReports = await _contentReportRepo.CountAsync(cancellationToken);

        var pendingReportsCount = await _contentReportRepo.CountByStatusAsync(Domain.Enums.ReportStatus.Pending, cancellationToken);

        var averageCompletionRate = await _viewRepo.AverageVideoCompletionAsync(cancellationToken);

        var revenueTrendChart = await _paymentRepo.GetMonthlyRevenueStats(DateTime.UtcNow.AddMonths(-5), _paymentSettings.PlatformFee, cancellationToken);


        return new DashboardOverviewDto(
            activeAccountsConunt,
            videosCount,
            subVideosCount,
            subscriberCount,
            totalTransactionValue,
            totalRevenue,
            paymentsCount,
            totalReports,
            pendingReportsCount,
            averageCompletionRate,
            revenueTrendChart);
    }
}
