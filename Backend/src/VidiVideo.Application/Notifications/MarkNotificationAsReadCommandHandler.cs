using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;

namespace VidiVideo.Application.Notifications;

public sealed class MarkNotificationAsReadCommandHandler : ICommandHandler<MarkNotificationAsReadCommand, bool>
{
    private readonly INotificationRepository _repo;
    private readonly IUnitOfWork _unitOfWork;
    private readonly ICurrentUser _currentUser;
    public MarkNotificationAsReadCommandHandler(INotificationRepository repo, IUnitOfWork unitOfWork, ICurrentUser currentUser)
    {
        _repo = repo;
        _unitOfWork = unitOfWork;
        _currentUser = currentUser;
    }

    public async Task<bool> HandleAsync(MarkNotificationAsReadCommand command, CancellationToken cancellationToken)
    {
        var userId = _currentUser.UserId ?? throw new UnauthorizedException("Must be logged in.");

        var notification = await _repo.GetByIdAsync(command.NotificationId) ?? throw new NotFoundException("Notification doesn't exist");

        if (notification.UserId != userId) throw new ForbiddenException("You cannot modify another user's notifications.");

        notification.ReadNotification();

        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return true;

    }
}
