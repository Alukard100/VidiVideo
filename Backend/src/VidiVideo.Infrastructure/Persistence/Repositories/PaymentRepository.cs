using Microsoft.EntityFrameworkCore;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Domain.Entities;

namespace VidiVideo.Infrastructure.Persistence.Repositories
{
    public sealed class PaymentRepository : IPaymentRepository
    {
        private readonly VidiVideoDbContext _db;
        public PaymentRepository(VidiVideoDbContext db)
        {
            _db = db;
        }

        public async Task CreatePaymentAsync(Payment Payment)
            => await _db.Payments.AddAsync(Payment);

        public async Task CreateSubscriptionAsync(CreatorSubscription Subscription)
            => await _db.CreatorSubscriptions.AddAsync(Subscription);

        public async Task<Payment?> GetPaymentByProviderIdAsync(string ProviderPaymentId)
            => await _db.Payments.FirstOrDefaultAsync(x => x.ProviderPaymentId == ProviderPaymentId);

        public async Task<CreatorSubscription?> GetSubscriptionByIdAsync(Guid Id)
            => await _db.CreatorSubscriptions.FirstOrDefaultAsync(x => x.Id == Id);

        public async Task<bool> HasActiveSubscriptionAsync(Guid SubscriberId, Guid CreatorId)
        {
            return await _db.CreatorSubscriptions.AnyAsync(x => x.SubscriberId == SubscriberId && x.CreatorId == CreatorId && x.IsActive);
        }
    }
}
