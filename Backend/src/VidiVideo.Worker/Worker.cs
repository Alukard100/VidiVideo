using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using System.Text;
using System.Text.Json;
using VidiVideo.Application.Media;
using VidiVideo.Application.Messaging;
using VidiVideo.Infrastructure.Messaging;
using VidiVideo.Infrastructure.Persistence;

namespace VidiVideo.Worker;

public sealed class Worker : BackgroundService
{
    private readonly ILogger<Worker> _logger;
    private readonly IServiceScopeFactory _scopeFactory;
    private readonly RabbitMqOptions _rabbitMqOptions;
    private readonly IConfiguration _configuration;

    public Worker(
        ILogger<Worker> logger,
        IServiceScopeFactory scopeFactory,
        IOptions<RabbitMqOptions> rabbitMqOptions,
        IConfiguration configuration)
    {
        _logger = logger;
        _scopeFactory = scopeFactory;
        _rabbitMqOptions = rabbitMqOptions.Value;
        _configuration = configuration;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                await RunConsumerAsync(stoppingToken);

                // Ako consumer iz nekog razloga normalno završi,
                // pokušaj ponovo nakon kratke pauze.
                await Task.Delay(
                    TimeSpan.FromSeconds(5),
                    stoppingToken);
            }
            catch (OperationCanceledException)
                when (stoppingToken.IsCancellationRequested)
            {
                break;
            }
            catch (Exception exception)
            {
                _logger.LogError(
                    exception,
                    "RabbitMQ worker connection failed. Retrying in 5 seconds.");

                await Task.Delay(
                    TimeSpan.FromSeconds(5),
                    stoppingToken);
            }
        }
    }

    private async Task RunConsumerAsync(CancellationToken stoppingToken)
    {
        var factory = new ConnectionFactory
        {
            HostName = _rabbitMqOptions.Host,
            Port = _rabbitMqOptions.Port,
            UserName = _rabbitMqOptions.UserName,
            Password = _rabbitMqOptions.Password
        };

        await using var connection =
            await factory.CreateConnectionAsync(
                stoppingToken);

        await using var channel =
            await connection.CreateChannelAsync(
                cancellationToken: stoppingToken);

        await channel.QueueDeclareAsync(
            queue: QueueNames.ImageCleanup,
            durable: true,
            exclusive: false,
            autoDelete: false,
            cancellationToken: stoppingToken);

        var consumer =
            new AsyncEventingBasicConsumer(channel);

        consumer.ReceivedAsync += async (_, args) =>
        {
            try
            {
                var json =
                    Encoding.UTF8.GetString(
                        args.Body.ToArray());

                var message =
                    JsonSerializer.Deserialize<
                        OldImageCleanupRequested>(
                        json);

                if (message == null ||
                    string.IsNullOrWhiteSpace(
                        message.ImageUrl))
                {
                    _logger.LogWarning(
                        "Received invalid image cleanup message.");

                    await channel.BasicAckAsync(
                        args.DeliveryTag,
                        multiple: false,
                        cancellationToken:
                            stoppingToken);

                    return;
                }

                await ProcessImageCleanupAsync(
                    message,
                    stoppingToken);

                await channel.BasicAckAsync(
                    args.DeliveryTag,
                    multiple: false,
                    cancellationToken:
                        stoppingToken);
            }
            catch (Exception exception)
            {
                _logger.LogError(
                    exception,
                    "Failed processing image cleanup message.");

                await channel.BasicNackAsync(
                    args.DeliveryTag,
                    multiple: false,
                    requeue: false,
                    cancellationToken:
                        stoppingToken);
            }
        };

        await channel.BasicConsumeAsync(
            queue: QueueNames.ImageCleanup,
            autoAck: false,
            consumer: consumer,
            cancellationToken: stoppingToken);

        _logger.LogInformation(
            "Image cleanup worker connected. Queue: {Queue}",
            QueueNames.ImageCleanup);

        await Task.Delay(
            Timeout.Infinite,
            stoppingToken);
    }

    private async Task ProcessImageCleanupAsync(OldImageCleanupRequested message, CancellationToken cancellationToken)
    {
        var canonicalImageUrl = GetCanonicalImagePath(message.ImageUrl);

        if (canonicalImageUrl is null)
        {
            _logger.LogWarning("Rejected non-canonical image cleanup path {ImageUrl}.", message.ImageUrl);
            return;
        }

        await using var scope = _scopeFactory.CreateAsyncScope();

        var db = scope.ServiceProvider.GetRequiredService<VidiVideoDbContext>();

        var usedAsAvatar = await db.Users.AnyAsync(user => user.AvatarUrl == canonicalImageUrl, cancellationToken);

        if (usedAsAvatar)
        {
            _logger.LogInformation("Image {ImageUrl} is still used as an avatar.", canonicalImageUrl);
            return;
        }

        var usedAsThumbnail = await db.Videos.AnyAsync(video => video.ThumbnailUrl == canonicalImageUrl, cancellationToken);

        if (usedAsThumbnail)
        {
            _logger.LogInformation("Image {ImageUrl} is still used as a video thumbnail.", canonicalImageUrl);
            return;
        }

        DeleteImageFile(canonicalImageUrl);
    }

    private void DeleteImageFile(string imageUrl)
    {
        var configuredDirectory =
            _configuration[
                "ImageSettings:ImageDirectory"]
            ?? "wwwroot/images";

        var imageDirectory =
            Path.GetFullPath(
                Path.Combine(
                    Directory.GetCurrentDirectory(),
                    configuredDirectory));

        // /images/foo.jpg -> foo.jpg
        // također uklanja pokušaje ../xyz
        var fileName =
            Path.GetFileName(imageUrl);

        if (string.IsNullOrWhiteSpace(fileName))
        {
            _logger.LogWarning(
                "Could not resolve filename from {ImageUrl}.",
                imageUrl);

            return;
        }

        var fullPath =
            Path.GetFullPath(
                Path.Combine(
                    imageDirectory,
                    fileName));

        // dodatna path traversal zaštita
        var rootWithSeparator =
            imageDirectory.TrimEnd(
                Path.DirectorySeparatorChar,
                Path.AltDirectorySeparatorChar)
            + Path.DirectorySeparatorChar;

        if (!fullPath.StartsWith(
            rootWithSeparator,
            StringComparison.Ordinal))
        {
            _logger.LogWarning(
                "Rejected unsafe image path {ImageUrl}.",
                imageUrl);

            return;
        }

        if (!File.Exists(fullPath))
        {
            _logger.LogInformation(
                "Orphan image {ImageUrl} no longer exists.",
                imageUrl);

            return;
        }

        File.Delete(fullPath);

        _logger.LogInformation(
            "Deleted orphan image {ImageUrl}.",
            imageUrl);
    }

    private string? GetCanonicalImagePath(string imageUrl)
    {
        if (string.IsNullOrWhiteSpace(imageUrl)) return null;

        var normalized = imageUrl.Trim().Replace('\\', '/');

        if (!normalized.StartsWith("/images/", StringComparison.OrdinalIgnoreCase))
        {
            return null;
        }

        if (normalized.Contains("..") ||
            normalized.Contains('?') ||
            normalized.Contains('#'))
        {
            return null;
        }

        var fileName = Path.GetFileName(normalized);

        if (string.IsNullOrWhiteSpace(fileName)) return null;

        var extension = Path.GetExtension(fileName).ToLowerInvariant();

        if (extension is not (".jpg" or ".jpeg" or ".png" or ".webp"))
        {
            _logger.LogWarning("Rejected unsupported image cleanup path {ImageUrl}.", imageUrl);

            return null;
        }

        var canonical = $"/images/{fileName}";

        if (!string.Equals(
                normalized,
                canonical,
                StringComparison.OrdinalIgnoreCase))
        {
            return null;
        }

        return canonical;
    }

}