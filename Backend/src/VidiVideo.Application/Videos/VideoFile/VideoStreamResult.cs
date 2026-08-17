namespace VidiVideo.Application.Videos.VideoFile;

public sealed record VideoStreamResult(
    Stream Stream,
    string ContentType);
