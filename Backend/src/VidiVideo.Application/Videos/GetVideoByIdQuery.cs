using VidiVideo.Application.Common;

namespace VidiVideo.Application.Videos;

public sealed record GetVideoByIdQuery(Guid videoId) : IQuery<VideoDto>;
