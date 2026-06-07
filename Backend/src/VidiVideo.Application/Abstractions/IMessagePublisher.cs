namespace VidiVideo.Application.Abstractions;

public interface IMessagePublisher
{
    Task PublishAsync<TMessage>(string queueName, TMessage message, CancellationToken cancellationToken);
}
