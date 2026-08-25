using VidiVideo.Domain.Enums;

namespace VidiVideo.Application.Payments.Refunds;

public sealed record RefundRequestDto(
    Guid Id,
    Guid PaymentId,
    Guid SubscriberId,
    string SubscriberName,
    Guid CreatorId,
    string CreatorName,
    decimal Amount,
    string Currency,
    RefundRequestStatus Status,
    DateTime RequestedAtUtc,
    DateTime? ReviewedAtUtc,
    Guid? ReviewedById);
