using VidiVideo.Application.Common;

namespace VidiVideo.Application.Videos.VideoFile;

public sealed record GetVideoStreamQuery(Guid VideoId) : IQuery<VideoStreamResult>;
