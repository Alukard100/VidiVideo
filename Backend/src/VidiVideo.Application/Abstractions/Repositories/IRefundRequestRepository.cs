using VidiVideo.Domain.Entities;
using VidiVideo.Domain.Enums;

namespace VidiVideo.Application.Abstractions.Repositories
{
    public interface IRefundRequestRepository
    {
        Task AddAsync(
        RefundRequest request,
        CancellationToken cancellationToken = default);

        Task<bool> HasPendingRequestAsync(
            Guid paymentId,
            CancellationToken cancellationToken = default);

        Task<RefundRequest?> GetByIdAsync(
            Guid id,
            CancellationToken cancellationToken = default);

        Task<List<RefundRequest>> GetPagedAsync(
        RefundRequestStatus? status,
        int page,
        int pageSize,
        CancellationToken cancellationToken = default);

        Task<int> CountAsync(
            RefundRequestStatus? status,
            CancellationToken cancellationToken = default);
    }
}
