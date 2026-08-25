using VidiVideo.Application.Common;

namespace VidiVideo.Application.Payments.Refunds;

public sealed record ApproveRefundRequestCommand(
    Guid RefundRequestId)
    : ICommand<bool>;
