using VidiVideo.Application.Common;

namespace VidiVideo.Application.Payments.PayPal;

public sealed record RefundPaymentCommand(
    Guid PaymentId)
    : ICommand<bool>;
