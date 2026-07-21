using VidiVideo.Application.Reports.RevenueReport;
using VidiVideo.Domain.Entities;

namespace VidiVideo.Application.Abstractions.Repositories;

public interface IPaymentRepository
{
    Task CreateSubscriptionAsync(CreatorSubscription Subscription);
    Task CreatePaymentAsync(Payment Payment);
    Task<bool> HasActiveSubscriptionAsync(Guid SubscriberId, Guid CreatorId);
    Task<CreatorSubscription?> GetSubscriptionByIdAsync(Guid Id);
    Task<Payment?> GetPaymentByProviderIdAsync(string ProviderPaymentId);
    Task<decimal> TotalRevenueAsync(DateTime? f = null);
    Task<int> TotalPaymentsAsync(DateTime? f = null);
    Task<int> TotalActiveSubsAsync();
    Task<List<CreatorRevenueStats>> TopCreatorsAsync(DateTime? f = null);
}
