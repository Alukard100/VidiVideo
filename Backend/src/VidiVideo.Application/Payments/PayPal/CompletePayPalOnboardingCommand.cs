using VidiVideo.Application.Common;

namespace VidiVideo.Application.Payments.PayPal;

public sealed record CompletePayPalOnboardingCommand
    : ICommand<bool>;