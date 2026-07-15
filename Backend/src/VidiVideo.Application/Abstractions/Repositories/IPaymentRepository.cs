using VidiVideo.Domain.Entities;

namespace VidiVideo.Application.Abstractions.Repositories;

public interface IPaymentRepository
{
    Task CreateSubscriptionAsync(CreatorSubscription Subscription);
    Task CreatePaymentAsync(Payment Payment);
    Task<bool> HasActiveSubscriptionAsync(Guid SubscriberId, Guid CreatorId);
    Task<CreatorSubscription?> GetSubscriptionByIdAsync(Guid Id);
    Task<Payment?> GetPaymentByProviderIdAsync(string ProviderPaymentId);
}
