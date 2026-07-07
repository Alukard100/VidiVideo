using VidiVideo.Application.Common;
using VidiVideo.Domain.Enums;

namespace VidiVideo.Application.Videos;

public sealed record UpdateVideoCommand(Guid videoId, Guid categoryId, string caption, string thumbnailUrl, VideoVisibility visibility, bool isPublished) : ICommand<Guid>;
