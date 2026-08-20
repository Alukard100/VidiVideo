using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;

namespace VidiVideo.Application.Notifications
{
    public sealed class GetNotificationsQueryHandler : IQueryHandler<GetNotificationsQuery, PagedResult<NotificationMessage>>
    {
        private readonly INotificationRepository _repo;
        private readonly IUserRepository _userRepository;
        private readonly ICurrentUser _currentUser;
        public GetNotificationsQueryHandler(INotificationRepository repo, IUserRepository userRepository, ICurrentUser currentUser)
        {
            _repo = repo;
            _userRepository = userRepository;
            _currentUser = currentUser;
        }

        public async Task<PagedResult<NotificationMessage>> HandleAsync(GetNotificationsQuery query, CancellationToken cancellationToken)
        {
            var userId = _currentUser.UserId ?? throw new UnauthorizedException("You must be logged in");

            if (!await _userRepository.ExistsByIdAsync(userId))
                throw new NotFoundException("User doesn't exist");

            var notifications = await _repo.GetUserNotificationsAsync(userId, query.Page, query.PageSize);

            var count = await _repo.CountAsync(userId);

            var items = notifications.Select(n => new NotificationMessage(
                n.Id, n.UserId, n.Title, n.Content, n.Type.ToString(), n.IsRead, n.CreatedAtUtc)).ToList();

            return new PagedResult<NotificationMessage>(items, query.Page, query.PageSize, count);

        }
    }
}
