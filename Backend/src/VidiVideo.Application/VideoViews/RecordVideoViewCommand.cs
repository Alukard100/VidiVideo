using VidiVideo.Application.Common;

namespace VidiVideo.Application.VideoViews;

public sealed record RecordVideoViewCommand(Guid VideoId, int WatchDurationSeconds, decimal CompletionRate) : ICommand<Guid>;

