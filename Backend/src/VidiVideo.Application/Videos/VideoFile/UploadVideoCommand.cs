using VidiVideo.Application.Common;

namespace VidiVideo.Application.Videos.VideoFile;

public sealed record UploadVideoCommand(
    Stream VideoStream,
    string FileName
) : ICommand<string>;