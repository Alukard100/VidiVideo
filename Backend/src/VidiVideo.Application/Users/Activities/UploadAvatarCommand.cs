using VidiVideo.Application.Common;

public sealed record UploadAvatarCommand(
    Stream ImageStream,
    string FileName)
    : ICommand<string>;