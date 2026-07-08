using VidiVideo.Application.Common;

namespace VidiVideo.Application.VideoViews;

public sealed record RecordVideoViewCommand(Guid UserId, Guid VideoId, int WatchDurationSeconds, decimal CompletionRate) : ICommand<Guid>;

