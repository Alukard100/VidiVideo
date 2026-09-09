using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System.Net;
using System.Net.Mail;
using VidiVideo.Application.Abstractions;

namespace VidiVideo.Infrastructure.Email;

internal class SmtpEmailSender : IEmailSender
{
    private readonly SmtpOptions _options;
    private readonly ILogger<SmtpEmailSender> _logger;

    public SmtpEmailSender(IOptions<SmtpOptions> options, ILogger<SmtpEmailSender> logger)
    {
        _options = options.Value;
        _logger = logger;
    }
    public async Task SendPasswordResetCodeAsync(string email, string code, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(_options.Host)) throw new InvalidOperationException("SMTP host is not configured.");

        if (string.IsNullOrWhiteSpace(_options.FromAddress)) throw new InvalidOperationException("SMTP sender address is not configured.");

        using var message = new MailMessage
        {
            From = new MailAddress(_options.FromAddress, _options.FromName),

            Subject = "VidiVideo password reset code",

            Body =
                $"Your VidiVideo password reset code is: {code}\n\n" +
                "This code expires in 10 minutes.\n\n" +
                "If you did not request a password reset, you can ignore this email.",

            IsBodyHtml = false
        };

        message.To.Add(email);

        using var client = new SmtpClient(_options.Host, _options.Port)
        {
            EnableSsl = _options.UseSsl,
            Credentials = new NetworkCredential(
                _options.UserName,
                _options.Password)
        };

        try
        {
            await client.SendMailAsync(message, cancellationToken);
        }
        catch (Exception exception)
        {
            _logger.LogError(exception, "Failed to send password reset email to {Email}.", email);

            throw;
        }
    }
}
