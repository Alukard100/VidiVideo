using VidiVideo.Domain.Common;
using VidiVideo.Domain.Enums;

namespace VidiVideo.Domain.Entities;

public sealed class Payment : AuditableEntity
{
    public Guid SubscriptionId { get; set; }
    public CreatorSubscription Subscription { get; set; } = null!;
    public decimal Amount { get; set; }
    public string Currency { get; set; } = "USD";
    public string Provider { get; set; } = "PayPal";
    public string ProviderPaymentId { get; set; } = string.Empty;
    public PaymentStatus Status { get; set; } = PaymentStatus.Pending;
    public DateTime? CompletedAtUtc { get; set; }
}
