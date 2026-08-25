using VidiVideo.Application.Common;

namespace VidiVideo.Application.Videos.VideoFile;

public sealed record GetModerationVideoStreamQuery(Guid VideoId) : IQuery<VideoStreamResult>;
