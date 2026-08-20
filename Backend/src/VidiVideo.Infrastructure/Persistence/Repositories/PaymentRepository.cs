using Microsoft.EntityFrameworkCore;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Reports.RevenueReport;
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

        public async Task<HashSet<Guid>> GetActiveSubscribedCreatorIdsAsync(Guid subscriberId)
        {
            var creatorIds = await _db.CreatorSubscriptions
                .Where(s =>
                    s.SubscriberId == subscriberId &&
                    s.IsActive &&
                    s.EndsAtUtc > DateTime.UtcNow)
                .Select(s => s.CreatorId)
                .ToListAsync();

            return creatorIds.ToHashSet();
        }

        public async Task<Payment?> GetPaymentByProviderIdAsync(string ProviderPaymentId)
            => await _db.Payments.FirstOrDefaultAsync(x => x.ProviderPaymentId == ProviderPaymentId);

        public async Task<CreatorSubscription?> GetSubscriptionByIdAsync(Guid Id)
            => await _db.CreatorSubscriptions.FirstOrDefaultAsync(x => x.Id == Id);

        public async Task<bool> HasActiveSubscriptionAsync(Guid SubscriberId, Guid CreatorId)
        {
            return await _db.CreatorSubscriptions.AnyAsync(x => x.SubscriberId == SubscriberId && x.CreatorId == CreatorId && x.IsActive && x.EndsAtUtc > DateTime.UtcNow);
        }

        public async Task<List<CreatorRevenueStats>> TopCreatorsAsync(DateTime? f = null)
        {
            var query = _db.Payments
                .Where(p => p.Status == Domain.Enums.PaymentStatus.Completed);

            if (f.HasValue)
                query = query.Where(p => p.CompletedAtUtc >= f.Value);

            return await query
                .GroupBy(p => new
                {
                    p.Subscription.CreatorId,
                    p.Subscription.Creator.DisplayName
                })
                .Select(g => new CreatorRevenueStats(
                    g.Key.DisplayName,
                    g.Where(x => x.Subscription.IsActive)
                        .Select(x => x.SubscriptionId)
                        .Distinct()
                        .Count(),
                    g.Sum(x => x.Amount),
                    g.Count()
                ))
                .OrderByDescending(x => x.Revenue)
                .Take(30)
                .ToListAsync();
        }

        public async Task<int> TotalActiveSubsAsync()
        {
            var query = _db.CreatorSubscriptions.AsQueryable();

            return await query.CountAsync(x => x.IsActive);
        }

        public async Task<int> TotalPaymentsAsync(DateTime? f = null)
        {
            var query = _db.Payments.AsQueryable();

            if (f.HasValue)
                query = query.Where(x => x.CompletedAtUtc >= f.Value);

            return await query.CountAsync(x => x.Status == Domain.Enums.PaymentStatus.Completed);
        }

        public async Task<decimal> TotalRevenueAsync(DateTime? f = null)
        {
            var query = _db.Payments.AsQueryable();

            if (f.HasValue)
                query = query.Where(x => x.CompletedAtUtc >= f.Value);

            return await query.Where(x => x.Status == Domain.Enums.PaymentStatus.Completed)
                .Select(x => (decimal?)x.Amount)
                .SumAsync() ?? 0m;
        }
    }
}
