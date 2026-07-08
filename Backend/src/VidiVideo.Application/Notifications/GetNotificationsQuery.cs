using VidiVideo.Application.Common;

namespace VidiVideo.Application.Notifications;

public sealed record GetNotificationsQuery(Guid UserId) : PagedRequest, IQuery<PagedResult<NotificationMessage>>;
