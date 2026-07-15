using VidiVideo.Application.Common;

namespace VidiVideo.Application.Notifications;

public sealed record GetNotificationsQuery() : PagedRequest, IQuery<PagedResult<NotificationMessage>>;
