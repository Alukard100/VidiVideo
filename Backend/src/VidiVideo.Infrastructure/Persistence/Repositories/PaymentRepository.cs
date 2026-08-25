using Microsoft.EntityFrameworkCore;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Dashboard;
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

        public async Task<Payment?> GetCompletedSubscriptionPaymentAsync(Guid subscriberId, Guid creatorId, CancellationToken cancellationToken = default)
        {
            return await _db.Payments
                .Include(x => x.Subscription)
                .Where(x => x.Subscription.SubscriberId == subscriberId && x.Subscription.CreatorId == creatorId && x.Status == Domain.Enums.PaymentStatus.Completed)
                .OrderByDescending(x => x.CompletedAtUtc)
                .FirstOrDefaultAsync(cancellationToken);
        }

        public async Task<List<DashboardRevenuePointDto>> GetMonthlyRevenueStats(DateTime f, CancellationToken cancellationToken = default)
        {
            var data = await _db.Payments
                .AsNoTracking()
                .Where(p =>
                    p.Status == Domain.Enums.PaymentStatus.Completed &&
                    p.CompletedAtUtc.HasValue &&
                    p.CompletedAtUtc.Value >= f)
                .GroupBy(p => new
                {
                    Year = p.CompletedAtUtc!.Value.Year,
                    Month = p.CompletedAtUtc.Value.Month
                })
                .Select(g => new
                {
                    Year = g.Key.Year,
                    Month = g.Key.Month,
                    Revenue = g.Sum(x => x.Amount)
                })
                .ToListAsync(cancellationToken);

            return data
                .OrderBy(x => x.Year)
                .ThenBy(x => x.Month)
                .Select(x => new DashboardRevenuePointDto(
                    x.Year,
                    x.Month,
                    x.Revenue))
                .ToList();
        }

        public async Task<Payment?> GetPaymentByIdAsync(Guid Id, CancellationToken cancellationToken = default)
            => await _db.Payments.FirstOrDefaultAsync(x => x.Id == Id, cancellationToken);


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
                .AsNoTracking()
                .Where(p =>
                    p.Status ==
                    Domain.Enums.PaymentStatus.Completed);

            if (f.HasValue)
                query = query.Where(p => p.CompletedAtUtc >= f.Value);

            var data = await query
                .Select(p => new
                {
                    p.Amount,
                    p.SubscriptionId,
                    CreatorId =
                        p.Subscription.CreatorId,
                    CreatorName =
                        p.Subscription.Creator.DisplayName,
                    SubscriptionIsActive =
                        p.Subscription.IsActive
                })
                .ToListAsync();

            return data
                .GroupBy(x => new
                {
                    x.CreatorId,
                    x.CreatorName
                })
                .Select(g => new CreatorRevenueStats(
                    g.Key.CreatorName,

                    g.Where(x => x.SubscriptionIsActive)
                        .Select(x => x.SubscriptionId)
                        .Distinct()
                        .Count(),

                    g.Sum(x => x.Amount),

                    g.Count()
                ))
                .OrderByDescending(x => x.Revenue)
                .Take(30)
                .ToList();
        }

        public async Task<int> TotalActiveSubsAsync(CancellationToken cancellationToken = default)
        {
            var query = _db.CreatorSubscriptions.AsQueryable();

            return await query.CountAsync(x => x.IsActive, cancellationToken);
        }

        public async Task<int> TotalPaymentsAsync(DateTime? f = null, CancellationToken cancellationToken = default)
        {
            var query = _db.Payments.AsQueryable();

            if (f.HasValue)
                query = query.Where(x => x.CompletedAtUtc >= f.Value);

            return await query.CountAsync(x => x.Status == Domain.Enums.PaymentStatus.Completed, cancellationToken);
        }

        public async Task<decimal> TotalRevenueAsync(DateTime? f = null, CancellationToken cancellationToken = default)
        {
            var query = _db.Payments.AsQueryable();

            if (f.HasValue)
                query = query.Where(x => x.CompletedAtUtc >= f.Value);

            return await query.Where(x => x.Status == Domain.Enums.PaymentStatus.Completed)
                .Select(x => (decimal?)x.Amount)
                .SumAsync(cancellationToken) ?? 0m;
        }
    }
}
