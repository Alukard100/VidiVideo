using Microsoft.Extensions.Options;
using RabbitMQ.Client;
using System.Text;
using System.Text.Json;
using VidiVideo.Application.Abstractions;

namespace VidiVideo.Infrastructure.Messaging;

public sealed class RabbitMqMessagePublisher : IMessagePublisher, IAsyncDisposable
{
    private readonly RabbitMqOptions _options;
    private readonly SemaphoreSlim _syncLock = new(1, 1);
    private IConnection? _connection;
    private IChannel? _channel;

    public RabbitMqMessagePublisher(IOptions<RabbitMqOptions> options)
    {
        _options = options.Value;
    }

    public async Task PublishAsync<TMessage>(string queueName, TMessage message, CancellationToken cancellationToken)
    {
        await _syncLock.WaitAsync(
            cancellationToken);

        try
        {
            await EnsureConnectedAsync(cancellationToken);

            await _channel!.QueueDeclareAsync(
                queue: queueName,
                durable: true,
                exclusive: false,
                autoDelete: false,
                cancellationToken:
                    cancellationToken);

            var body = Encoding.UTF8.GetBytes(JsonSerializer.Serialize(message));

            var properties =
                new BasicProperties
                {
                    Persistent = true
                };

            await _channel.BasicPublishAsync(
                exchange: string.Empty,
                routingKey: queueName,
                mandatory: false,
                basicProperties: properties,
                body: body,
                cancellationToken:
                    cancellationToken);
        }
        catch
        {
            await ResetConnectionAsync();
            throw;
        }
        finally
        {
            _syncLock.Release();
        }
    }

    private async Task EnsureConnectedAsync(CancellationToken cancellationToken)
    {
        if (_connection is { IsOpen: true } && _channel is { IsOpen: true })
            return;

        await ResetConnectionAsync();

        var factory =
            new ConnectionFactory
            {
                HostName = _options.Host,
                Port = _options.Port,
                UserName = _options.UserName,
                Password = _options.Password
            };

        _connection = await factory.CreateConnectionAsync(cancellationToken);

        _channel = await _connection.CreateChannelAsync(cancellationToken: cancellationToken);
    }

    private async Task ResetConnectionAsync()
    {
        if (_channel is not null)
        {
            try
            {
                await _channel.DisposeAsync();
            }
            catch
            {
                // Best effort cleanup.
            }

            _channel = null;
        }

        if (_connection is not null)
        {
            try
            {
                await _connection.DisposeAsync();
            }
            catch
            {
                // Best effort cleanup.
            }

            _connection = null;
        }
    }

    public async ValueTask DisposeAsync()
    {
        await _syncLock.WaitAsync();

        try
        {
            await ResetConnectionAsync();
        }
        finally
        {
            _syncLock.Release();
            _syncLock.Dispose();
        }
    }
}