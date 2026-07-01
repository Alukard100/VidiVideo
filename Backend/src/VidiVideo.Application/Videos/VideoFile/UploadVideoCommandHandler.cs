using FFMpegCore;
using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;

namespace VidiVideo.Application.Videos.VideoFile
{
    public sealed class UploadVideoCommandHandler : ICommandHandler<UploadVideoCommand, string>
    {
        private readonly IVideoStorageService _videoStorageService;
        private static readonly string[] AllowedExtensions = [
            ".mp4",
            ".mov",
            ".webm"
            ];
        const long maxSize = 500 * 1024 * 1024; //500MB

        public UploadVideoCommandHandler(IVideoStorageService videoStorageService)
        {
            _videoStorageService = videoStorageService;
        }

        public async Task<string> HandleAsync(UploadVideoCommand command, CancellationToken cancellationToken)
        {

            var extension = Path.GetExtension(command.FileName);

            if (string.IsNullOrEmpty(extension) || !AllowedExtensions.Contains(extension.ToLowerInvariant()))
                throw new ValidationException("Invalid video format.");

            if (command.VideoStream.Length > maxSize)
            {
                throw new ValidationException(
                    "Video exceeds maximum size.");
            }

            var tempPath = Path.GetTempFileName();

            try
            {
                using (var stream = File.Create(tempPath))
                {
                    await command.VideoStream.CopyToAsync(stream, cancellationToken);
                }

                var mediaInfo =
                    await FFProbe.AnalyseAsync(tempPath);

                if (mediaInfo.PrimaryVideoStream is null)
                {
                    throw new ValidationException(
                        "File does not contain a valid video stream.");
                }

                if (mediaInfo.Duration > TimeSpan.FromMinutes(5))
                {
                    throw new ValidationException(
                        "Video exceeds maximum duration.");
                }

                command.VideoStream.Position = 0;

                return await _videoStorageService.UploadAsync(command.VideoStream, command.FileName);

            }
            finally
            {
                if (File.Exists(tempPath))
                    File.Delete(tempPath);
            }


        }
    }
}
