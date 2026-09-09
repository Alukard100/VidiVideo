namespace VidiVideo.Application.Abstractions;

public interface IEmailSender
{
    Task SendPasswordResetCodeAsync(string email, string code, CancellationToken cancellationToken = default);
}
