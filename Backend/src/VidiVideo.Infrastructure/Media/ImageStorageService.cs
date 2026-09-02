using Microsoft.Extensions.Configuration;
using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.DTOs;

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

        public async Task<string> UploadAsync(ProcessedImage processedImage, CancellationToken cancellationToken = default)
        {
            if (processedImage.Bytes is null || processedImage.Bytes.Length == 0)
            {
                throw new InvalidOperationException(
                    "Processed image contains no data.");
            }

            if (string.IsNullOrWhiteSpace(processedImage.Extension))
            {
                throw new InvalidOperationException(
                    "Processed image extension is missing.");
            }

            if (string.IsNullOrWhiteSpace(processedImage.Extension))
                throw new InvalidOperationException(
                    "Processed image extension is missing.");

            var extension = processedImage.Extension.StartsWith('.')
                ? processedImage.Extension.ToLowerInvariant()
                : $".{processedImage.Extension.ToLowerInvariant()}";

            var uniqueName = $"{Guid.NewGuid():N}{extension}";

            var fullPath = Path.Combine(_imageDirectory, uniqueName);

            await File.WriteAllBytesAsync(fullPath, processedImage.Bytes, cancellationToken);

            return $"/images/{uniqueName}";
        }
    }
}
