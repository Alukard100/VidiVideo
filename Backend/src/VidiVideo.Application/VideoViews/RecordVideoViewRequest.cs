namespace VidiVideo.Application.VideoViews;

public sealed record RecordVideoViewRequest(Guid VideoId, int WatchDurationSeconds, decimal CompletionRate);
