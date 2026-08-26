using VidiVideo.Application.Common;

namespace VidiVideo.Application.Payments.PayPal;

public sealed record CreatePayPalOnboardingCommand
    : ICommand<PayPalOnboardingResult>;