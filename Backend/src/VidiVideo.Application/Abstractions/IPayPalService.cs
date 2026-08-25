using VidiVideo.Application.Payments.PayPal;

namespace VidiVideo.Application.Abstractions;

public interface IPayPalService
{
    Task<PayPalOrderDto> CreateOrderAsync(decimal amount);
    Task<PayPalCaptureResult> CaptureOrderAsync(string orderId);
    Task<PayPalRefundResult> RefundAsync(string captureId, decimal amount, string currency);
}
