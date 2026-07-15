using VidiVideo.Domain.Common;
using VidiVideo.Domain.Enums;

namespace VidiVideo.Domain.Entities;

public sealed class Payment : AuditableEntity
{
    public Guid SubscriptionId { get; private set; }
    public CreatorSubscription Subscription { get; set; } = null!;
    public decimal Amount { get; private set; }
    public string Currency { get; private set; } = "USD";
    public string Provider { get; private set; } = "PayPal";
    public string ProviderPaymentId { get; private set; } = string.Empty;
    public PaymentStatus Status { get; private set; } = PaymentStatus.Pending;
    public DateTime? CompletedAtUtc { get; private set; }

    protected Payment() { }

    public Payment(Guid subscriptionid, decimal amount, string providerPaymentId)
    {
        SubscriptionId = subscriptionid;
        Amount = amount;
        ProviderPaymentId = providerPaymentId;
        Status = PaymentStatus.Pending;
    }

    public void MarkCompleted()
    {
        Status = PaymentStatus.Completed;
        CompletedAtUtc = DateTime.UtcNow;
    }

    public void MarkFailed()
        => Status = PaymentStatus.Failed;
}
