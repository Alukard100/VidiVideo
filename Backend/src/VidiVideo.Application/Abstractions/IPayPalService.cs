using VidiVideo.Application.Payments.PayPal;

namespace VidiVideo.Application.Abstractions;

public interface IPayPalService
{
    Task<PayPalOrderDto> CreateOrderAsync(decimal amount);
    Task<bool> CaptureOrderAsync(string orderId);
}
