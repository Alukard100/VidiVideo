namespace VidiVideo.Application.Payments.PayPal;

public sealed record PayPalCaptureResult(bool Success, string? CaptureId);
