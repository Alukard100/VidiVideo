using VidiVideo.Domain.Common;
using VidiVideo.Domain.Enums;

namespace VidiVideo.Domain.Entities;

public sealed class RefundRequest : AuditableEntity
{
    public Guid PaymentId { get; private set; }
    public Payment Payment { get; private set; } = null!;

    public RefundRequestStatus Status { get; private set; }
        = RefundRequestStatus.Pending;

    public Guid? ReviewedById { get; private set; }
    public AppUser? ReviewedBy { get; private set; }

    protected RefundRequest() { }

    public RefundRequest(Guid paymentId)
    {
        PaymentId = paymentId;
        Status = RefundRequestStatus.Pending;
    }

    public void Approve(Guid reviewerId)
    {
        if (Status != RefundRequestStatus.Pending)
            throw new InvalidOperationException(
                "Refund request has already been reviewed.");

        Status = RefundRequestStatus.Approved;
        ReviewedById = reviewerId;
        UpdatedAtUtc = DateTime.UtcNow;
    }

    public void Reject(Guid reviewerId)
    {
        if (Status != RefundRequestStatus.Pending)
            throw new InvalidOperationException(
                "Refund request has already been reviewed.");

        Status = RefundRequestStatus.Rejected;
        ReviewedById = reviewerId;
        UpdatedAtUtc = DateTime.UtcNow;
    }
}
