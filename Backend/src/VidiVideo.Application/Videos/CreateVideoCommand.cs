using VidiVideo.Application.Common;
using VidiVideo.Domain.Enums;

namespace VidiVideo.Application.Videos;

public sealed record CreateVideoCommand(Guid CreatorId, Guid CategoryId, string Caption, string VideoUrl, string ThumbnailUrl, VideoVisibility Visibility, bool IsPublished) : ICommand<Guid>;

