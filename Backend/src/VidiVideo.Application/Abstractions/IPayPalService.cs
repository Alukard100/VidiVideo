namespace VidiVideo.Application.Abstractions;

public interface IPayPalService
{
    Task<string> CreateOrderAsync(decimal amount);
    Task<bool> CaptureOrderAsync(string orderId);
}
