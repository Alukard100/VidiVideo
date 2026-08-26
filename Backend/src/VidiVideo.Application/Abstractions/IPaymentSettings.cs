namespace VidiVideo.Application.Abstractions;

public interface IPaymentSettings
{
    decimal SubscriptionPrice { get; }
    decimal PlatformFee { get; }
}
