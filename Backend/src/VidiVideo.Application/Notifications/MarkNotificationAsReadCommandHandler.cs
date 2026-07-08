using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;

namespace VidiVideo.Application.Notifications;

public sealed class MarkNotificationAsReadCommandHandler : ICommandHandler<MarkNotificationAsReadCommand, bool>
{
    private readonly INotificationRepository _repo;
    private readonly IUnitOfWork _unitOfWork;
    public MarkNotificationAsReadCommandHandler(INotificationRepository repo, IUnitOfWork unitOfWork)
    {
        _repo = repo;
        _unitOfWork = unitOfWork;
    }

    public async Task<bool> HandleAsync(MarkNotificationAsReadCommand command, CancellationToken cancellationToken)
    {
        var notification = await _repo.GetByIdAsync(command.NotificationId) ?? throw new NotFoundException("Notification doesn't exist");

        notification.ReadNotification();

        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return true;

    }
}
