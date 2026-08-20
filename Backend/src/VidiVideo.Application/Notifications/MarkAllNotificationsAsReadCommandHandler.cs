using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;

namespace VidiVideo.Application.Notifications;

public sealed class MarkAllNotificationsAsReadCommandHandler : ICommandHandler<MarkAllNotificationsAsReadCommand, bool>
{
    private readonly INotificationRepository _repo;
    private readonly ICurrentUser _currentUser;
    private readonly IUnitOfWork _unitOfWork;
    public MarkAllNotificationsAsReadCommandHandler(INotificationRepository repo, IUnitOfWork unitOfWork, ICurrentUser currentUser)
    {
        _repo = repo;
        _unitOfWork = unitOfWork;
        _currentUser = currentUser;
    }
    public async Task<bool> HandleAsync(MarkAllNotificationsAsReadCommand command, CancellationToken cancellationToken)
    {
        var userId = _currentUser.UserId ?? throw new UnauthorizedException("Must be logged in.");

        var notifications = await _repo.GetUnreadByUserAsync(userId, cancellationToken);

        foreach (var notification in notifications)
        {
            notification.ReadNotification();
        }

        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return true;
    }
}
