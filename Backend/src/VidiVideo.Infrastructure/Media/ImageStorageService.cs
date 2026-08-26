using Microsoft.Extensions.Configuration;
using VidiVideo.Application.Abstractions;

namespace VidiVideo.Infrastructure.Media
{
    public sealed class ImageStorageService : IImageStorageService
    {
        private readonly string _imageDirectory;
        public ImageStorageService(IConfiguration configuration)
        {
            var configuredPath =
                configuration["ImageSettings:ImageDirectory"]
                ?? throw new InvalidOperationException(
                    "Image directory is not configured.");

            _imageDirectory = Path.Combine(Directory.GetCurrentDirectory(), configuredPath);

            if (!Directory.Exists(_imageDirectory))
                Directory.CreateDirectory(_imageDirectory);
        }

        public async Task<string> UploadAsync(Stream fileStream, string fileName)
        {
            var extension = Path.GetExtension(fileName);
            var uniqueName = $"{Guid.NewGuid()}{extension}";

            var fullPath = Path.Combine(_imageDirectory, uniqueName);

            using (var stream = new FileStream(fullPath, FileMode.Create))
            {
                await fileStream.CopyToAsync(stream);
            }

            return $"/images/{uniqueName}";
        }
    }
}
