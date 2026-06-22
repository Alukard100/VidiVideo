using Microsoft.Extensions.Configuration;
using VidiVideo.Application.Abstractions;

namespace VidiVideo.Infrastructure.Media
{
    public sealed class VideoStorageService : IVideoStorageService
    {
        private readonly string _videoDirectory;
        private readonly IConfiguration _configuration;

        public VideoStorageService(IConfiguration configuration)
        {
            _configuration = configuration;

            _videoDirectory = Path.Combine(Directory.GetCurrentDirectory(), _configuration["ImageSettings:VideoDirectory"]);

            if (!Directory.Exists(_videoDirectory))
                Directory.CreateDirectory(_videoDirectory);
        }

        public async Task<string> UploadAsync(Stream videoFile, string videoName)
        {
            var extension = Path.GetExtension(videoName);

            var uniqueName = $"{Guid.NewGuid()}{extension}";

            var fullPath = Path.Combine(
                _videoDirectory,
                uniqueName);

            using var stream = new FileStream(
                fullPath, FileMode.Create);

            await videoFile.CopyToAsync(stream);

            return $"/videos/{uniqueName}";
        }
    }

}
