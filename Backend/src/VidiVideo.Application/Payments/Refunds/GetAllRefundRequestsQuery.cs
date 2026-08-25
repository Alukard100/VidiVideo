using VidiVideo.Application.Common;
using VidiVideo.Domain.Enums;

namespace VidiVideo.Application.Payments.Refunds;

public sealed record GetAllRefundRequestsQuery : PagedRequest, IQuery<PagedResult<RefundRequestDto>>
{
    public RefundRequestStatus? Status { get; init; }
}
