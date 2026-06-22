using VidiVideo.Application.Common;

namespace VidiVideo.Application.Videos.Thumbnails;

public sealed record CreateThumbnailCommand(Stream fileStream, string fileName) : ICommand<string>;
