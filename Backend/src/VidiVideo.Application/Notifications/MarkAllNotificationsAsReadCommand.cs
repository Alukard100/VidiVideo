using VidiVideo.Application.Common;

namespace VidiVideo.Application.Notifications;

public sealed record MarkAllNotificationsAsReadCommand : ICommand<bool>;
