using Microsoft.Extensions.Configuration;
using VidiVideo.Application.Abstractions;

namespace VidiVideo.Infrastructure.Media
{
    public sealed class ImageStorageService : IImageStorageService
    {
        private readonly string _imageDirectory;
        private readonly IConfiguration _configuration;

        public ImageStorageService(IConfiguration configuration)
        {
            _configuration = configuration;

            _imageDirectory = Path.Combine(Directory.GetCurrentDirectory(), _configuration["ImageSettings:ImageDirectory"]);

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
