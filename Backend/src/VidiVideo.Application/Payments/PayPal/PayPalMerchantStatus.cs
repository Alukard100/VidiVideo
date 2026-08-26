namespace VidiVideo.Application.Payments.PayPal;

public sealed record PayPalMerchantStatus(
    string MerchantId,
    bool PaymentsReceivable,
    bool PrimaryEmailConfirmed);