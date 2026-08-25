using Microsoft.EntityFrameworkCore;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Domain.Entities;
using VidiVideo.Domain.Enums;

namespace VidiVideo.Infrastructure.Persistence.Repositories
{
    public sealed class RefundRequestRepository : IRefundRequestRepository
    {
        private readonly VidiVideoDbContext _db;
        public RefundRequestRepository(VidiVideoDbContext db)
        {
            _db = db;
        }

        public async Task AddAsync(RefundRequest request, CancellationToken cancellationToken = default)
            => await _db.RefundRequests.AddAsync(request, cancellationToken);

        public async Task<int> CountAsync(RefundRequestStatus? status, CancellationToken cancellationToken = default)
        {
            var query = _db.RefundRequests
                .AsNoTracking()
                .Where(x => !x.IsDeleted)
                .AsQueryable();

            if (status.HasValue)
            {
                query = query.Where(
                    x => x.Status == status.Value);
            }

            return await query.CountAsync(
                cancellationToken);
        }

        public async Task<RefundRequest?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
            => await _db.RefundRequests
                .Include(x => x.Payment)
                    .ThenInclude(x => x.Subscription)
                        .ThenInclude(x => x.Subscriber)
                .Include(x => x.Payment)
                    .ThenInclude(x => x.Subscription)
                        .ThenInclude(x => x.Creator)
                .FirstOrDefaultAsync(x => x.Id == id && !x.IsDeleted, cancellationToken);

        public async Task<List<RefundRequest>> GetPagedAsync(RefundRequestStatus? status, int page, int pageSize, CancellationToken cancellationToken = default)
        {
            var query = _db.RefundRequests
                .AsNoTracking()
                .Include(x => x.Payment)
                    .ThenInclude(x => x.Subscription)
                        .ThenInclude(x => x.Subscriber)
                .Include(x => x.Payment)
                    .ThenInclude(x => x.Subscription)
                        .ThenInclude(x => x.Creator)
                .Where(x => !x.IsDeleted)
                .AsQueryable();

            if (status.HasValue)
            {
                query = query.Where(x => x.Status == status.Value);
            }

            return await query.OrderByDescending(x => x.CreatedAtUtc)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync(cancellationToken);

        }
        public async Task<bool> HasPendingRequestAsync(Guid paymentId, CancellationToken cancellationToken = default)
            => await _db.RefundRequests.AnyAsync(x => x.PaymentId == paymentId && x.Status == Domain.Enums.RefundRequestStatus.Pending && !x.IsDeleted, cancellationToken);
    }
}
