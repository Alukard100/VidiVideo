using VidiVideo.Application.Dashboard;
using VidiVideo.Application.Reports.RevenueReport;
using VidiVideo.Domain.Entities;

namespace VidiVideo.Application.Abstractions.Repositories;

public interface IPaymentRepository
{
    Task CreateSubscriptionAsync(CreatorSubscription Subscription);
    Task CreatePaymentAsync(Payment Payment);
    Task<bool> HasActiveSubscriptionAsync(Guid SubscriberId, Guid CreatorId);
    Task<CreatorSubscription?> GetSubscriptionByIdAsync(Guid Id);
    Task<Payment?> GetPaymentByIdAsync(Guid Id, CancellationToken cancellationToken = default);
    Task<Payment?> GetPaymentByProviderIdAsync(string ProviderPaymentId);
    Task<Payment?> GetCompletedSubscriptionPaymentAsync(Guid subscriberId, Guid creatorId, CancellationToken cancellationToken = default);
    Task<decimal> TotalRevenueAsync(DateTime? f = null, CancellationToken cancellationToken = default);
    Task<int> TotalPaymentsAsync(DateTime? f = null, CancellationToken cancellationToken = default);
    Task<int> TotalActiveSubsAsync(CancellationToken cancellationToken = default);
    Task<List<CreatorRevenueStats>> TopCreatorsAsync(DateTime? f = null);
    Task<HashSet<Guid>> GetActiveSubscribedCreatorIdsAsync(Guid subscriberId);
    Task<List<DashboardRevenuePointDto>> GetMonthlyRevenueStats(DateTime f, decimal platformFee, CancellationToken cancellationToken = default);
}
