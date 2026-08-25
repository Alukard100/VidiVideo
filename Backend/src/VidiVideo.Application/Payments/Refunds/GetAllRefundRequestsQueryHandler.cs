using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;

namespace VidiVideo.Application.Payments.Refunds;

public sealed class GetAllRefundRequestsQueryHandler : IQueryHandler<GetAllRefundRequestsQuery, PagedResult<RefundRequestDto>>
{
    private readonly IRefundRequestRepository _refundRequestRepository;
    public GetAllRefundRequestsQueryHandler(IRefundRequestRepository refundRequestRepository)
    {
        _refundRequestRepository = refundRequestRepository;
    }

    public async Task<PagedResult<RefundRequestDto>> HandleAsync(GetAllRefundRequestsQuery query, CancellationToken cancellationToken)
    {
        var requests =
            await _refundRequestRepository.GetPagedAsync(
                query.Status,
                query.Page,
                query.PageSize,
                cancellationToken);

        var count =
            await _refundRequestRepository.CountAsync(
                query.Status,
                cancellationToken);

        var items = requests.Select(x =>
            new RefundRequestDto(
                x.Id,
                x.PaymentId,

                x.Payment.Subscription.SubscriberId,
                x.Payment.Subscription.Subscriber.DisplayName,

                x.Payment.Subscription.CreatorId,
                x.Payment.Subscription.Creator.DisplayName,

                x.Payment.Amount,
                x.Payment.Currency,

                x.Status,
                x.CreatedAtUtc,
                x.UpdatedAtUtc,
                x.ReviewedById
            ))
            .ToList();

        return new PagedResult<RefundRequestDto>(
            items,
            query.Page,
            query.PageSize,
            count);
    }
}
