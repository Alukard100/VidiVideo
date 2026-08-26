using Microsoft.Extensions.Configuration;
using VidiVideo.Application.Abstractions;

namespace VidiVideo.Infrastructure.Payments;

public sealed class PaymentSettings : IPaymentSettings
{
    private readonly IConfiguration _config;
    public PaymentSettings(IConfiguration config)
    {
        _config = config;
    }
    public decimal SubscriptionPrice => _config.GetValue<decimal>("PayPal:SubscriptionPrice");

    public decimal PlatformFee => _config.GetValue<decimal>("PayPal:PlatformFee");
}
