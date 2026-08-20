namespace VidiVideo.Application.Payments.PayPal;

public sealed record PayPalOrderDto(
    string OrderId,
    string ApprovalUrl);
