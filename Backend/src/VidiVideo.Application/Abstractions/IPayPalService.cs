using VidiVideo.Application.Payments.PayPal;

namespace VidiVideo.Application.Abstractions;

public interface IPayPalService
{
    Task<PayPalOrderDto> CreateOrderAsync(decimal amount, decimal platformFee, string sellerMechantId);
    Task<PayPalCaptureResult> CaptureOrderAsync(string orderId);
    Task<PayPalRefundResult> RefundAsync(string captureId, decimal amount, string currency, string sellerMerchantId);
    Task<PayPalOnboardingResult> CreateSellerOnboardingAsync(Guid userId, string email);
    Task<PayPalMerchantStatus?> GetMerchantStatusByTrackingIdAsync(Guid userId);
}
