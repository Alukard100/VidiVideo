using VidiVideo.Application.Common;

namespace VidiVideo.Application.Payments.PayPal;

public sealed record CapturePayPalOrderCommand(string OrderId) : ICommand<bool>;
