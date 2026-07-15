using VidiVideo.Application.Common;
using VidiVideo.Domain.Enums;

namespace VidiVideo.Application.Videos;

public sealed record UpdateVideoCommand(Guid VideoId, Guid CategoryId, string Caption, string ThumbnailUrl, VideoVisibility Visibility, bool IsPublished) : ICommand<Guid>;
