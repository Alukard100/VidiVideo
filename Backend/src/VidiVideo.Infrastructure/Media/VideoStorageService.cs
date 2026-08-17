using Microsoft.Extensions.Configuration;
using VidiVideo.Application.Abstractions;

namespace VidiVideo.Infrastructure.Media
{
    public sealed class VideoStorageService : IVideoStorageService
    {
        private readonly string _videoDirectory;
        public VideoStorageService(IConfiguration configuration)
        {
            var configuredPath =
                configuration["ImageSettings:VideoDirectory"]
                ?? throw new InvalidOperationException(
                    "Video directory is not configured.");

            _videoDirectory = Path.Combine(Directory.GetCurrentDirectory(), configuredPath);

            if (!Directory.Exists(_videoDirectory))
                Directory.CreateDirectory(_videoDirectory);
        }

        public async Task<string> UploadAsync(Stream videoFile, string videoName, CancellationToken cancellationToken = default)
        {
            var extension = Path.GetExtension(videoName).ToLowerInvariant();

            var uniqueName = $"{Guid.NewGuid()}{extension}";

            var fullPath = Path.Combine(
                _videoDirectory,
                uniqueName);

            await using var stream = new FileStream(
                fullPath, FileMode.CreateNew, FileAccess.Write, FileShare.None);

            await videoFile.CopyToAsync(stream, cancellationToken);

            return uniqueName;
        }
        public Task<Stream> OpenReadAsync(string storageKey, CancellationToken cancellationToken = default)
        {
            var safeFileName = Path.GetFileName(storageKey);

            var fullPath = Path.Combine(_videoDirectory, safeFileName);

            if (!File.Exists(fullPath))
                throw new FileNotFoundException("Video file was not found.");

            Stream stream = new FileStream(fullPath, FileMode.Open, FileAccess.Read, FileShare.Read);

            return Task.FromResult(stream);
        }

        public string GetContentType(string storageKey)
        {
            return Path.GetExtension(storageKey)
                .ToLowerInvariant() switch
            {
                ".mp4" => "video/mp4",
                ".webm" => "video/webm",
                ".mov" => "video/quicktime",
                _ => "application/octet-stream"
            };
        }


    }

}
