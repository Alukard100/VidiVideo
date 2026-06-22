using SixLabors.ImageSharp;
using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;

namespace VidiVideo.Application.Videos.Thumbnails
{
    public sealed class CreateThumbnailCommandHandler : ICommandHandler<CreateThumbnailCommand, string>
    {
        private readonly IImageStorageService _imageStorageService;
        private static readonly string[] AllowedExtensions = [
            ".jpg",
            ".jpeg",
            ".png",
            ".webp"
            ];

        const long maxSize = 5 * 1024 * 1024; //5MB

        public CreateThumbnailCommandHandler(IImageStorageService imageStorageService)
        {
            _imageStorageService = imageStorageService;
        }

        public async Task<string> HandleAsync(CreateThumbnailCommand command, CancellationToken cancellationToken)
        {
            var extension = Path.GetExtension(command.fileName);

            if (string.IsNullOrEmpty(extension) || !AllowedExtensions.Contains(extension.ToLowerInvariant()))
                throw new ValidationException("Invalid image format.");

            if (command.fileStream.Length > maxSize)
                throw new ValidationException("Image is too large");

            try
            {
                using var image = await Image.LoadAsync(command.fileStream, cancellationToken);
            }
            catch
            {
                throw new ValidationException("Invalid image file.");
            }

            string path = await _imageStorageService.UploadAsync(command.fileStream, command.fileName);

            return path;
        }
    }
}
