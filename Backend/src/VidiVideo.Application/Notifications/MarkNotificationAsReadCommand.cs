using VidiVideo.Application.Common;

namespace VidiVideo.Application.Notifications;

public sealed record MarkNotificationAsReadCommand(Guid NotificationId) : ICommand<bool>;
