using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;

namespace VidiVideo.Application.Notifications
{
    public sealed class GetNotificationsQueryHandler : IQueryHandler<GetNotificationsQuery, PagedResult<NotificationMessage>>
    {
        private readonly INotificationRepository _repo;
        private readonly IUserRepository _userRepository;
        public GetNotificationsQueryHandler(INotificationRepository repo, IUserRepository userRepository)
        {
            _repo = repo;
            _userRepository = userRepository;
        }

        public async Task<PagedResult<NotificationMessage>> HandleAsync(GetNotificationsQuery query, CancellationToken cancellationToken)
        {
            if (await _userRepository.ExistsByIdAsync(query.UserId))
                throw new NotFoundException("User doesn't exist");

            var notifications = await _repo.GetUserNotificationsAsync(query.UserId, query.Page, query.PageSize);

            var count = await _repo.CoutnAsync(query.UserId);

            var items = notifications.Select(n => new NotificationMessage(
                n.UserId, n.Title, n.Content, n.Type.ToString(), n.IsRead, n.CreatedAtUtc)).ToList();

            return new PagedResult<NotificationMessage>(items, query.Page, query.PageSize, count);

        }
    }
}
