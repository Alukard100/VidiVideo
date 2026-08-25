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
    public DateTime? RefundedAtUtc { get; private set; }
    public string? ProviderRefundId { get; private set; }
    public string? ProviderCaptureId { get; private set; }

    protected Payment() { }

    public Payment(Guid subscriptionid, decimal amount, string providerPaymentId)
    {
        SubscriptionId = subscriptionid;
        Amount = amount;
        ProviderPaymentId = providerPaymentId;
        Status = PaymentStatus.Pending;
    }

    public void MarkCompleted(
        string providerCaptureId)
    {
        if (string.IsNullOrWhiteSpace(
            providerCaptureId))
        {
            throw new ArgumentException(
                "Capture ID is required.",
                nameof(providerCaptureId));
        }

        Status = PaymentStatus.Completed;
        CompletedAtUtc = DateTime.UtcNow;
        ProviderCaptureId = providerCaptureId;
        UpdatedAtUtc = DateTime.UtcNow;
    }

    public void MarkFailed()
        => Status = PaymentStatus.Failed;

    public void MarkRefunded(string providerRefundId)
    {
        if (Status != PaymentStatus.Completed)
            throw new InvalidOperationException(
                "Only completed payments can be refunded.");

        Status = PaymentStatus.Refunded;
        ProviderRefundId = providerRefundId;
        RefundedAtUtc = DateTime.UtcNow;
        UpdatedAtUtc = DateTime.UtcNow;
    }
}
