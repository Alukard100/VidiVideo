using VidiVideo.Application.Common;

namespace VidiVideo.Application.Payments.PayPal;

public sealed record CreatePayPalOrderCommand(Guid CreatorId, decimal Amount) : ICommand<string>;
