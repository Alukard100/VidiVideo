using VidiVideo.Application.Common;

namespace VidiVideo.Application.Payments.Refunds;

public sealed record RejectRefundRequestCommand(
    Guid RefundRequestId)
    : ICommand<bool>;