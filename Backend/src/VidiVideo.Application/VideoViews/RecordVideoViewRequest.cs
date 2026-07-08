namespace VidiVideo.Application.VideoViews;

public sealed record RecordVideoViewRequest(Guid UserId, Guid VideoId, int WatchDurationSeconds, decimal CompletionRate);
