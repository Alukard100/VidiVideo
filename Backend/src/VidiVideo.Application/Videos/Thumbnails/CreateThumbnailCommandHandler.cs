using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Common;
using VidiVideo.Domain.Enums;

namespace VidiVideo.Application.Videos.Thumbnails
{
    public sealed class CreateThumbnailCommandHandler : ICommandHandler<CreateThumbnailCommand, string>
    {
        private readonly IImageStorageService _imageStorageService;
        private readonly IImageProcessor _imageProcessor;

        public CreateThumbnailCommandHandler(IImageStorageService imageStorageService, IImageProcessor imageProcessor)
        {
            _imageStorageService = imageStorageService;
            _imageProcessor = imageProcessor;
        }

        public async Task<string> HandleAsync(CreateThumbnailCommand command, CancellationToken cancellationToken)
        {
            var processedImage = await _imageProcessor.ProcessAsync(command.fileStream, command.fileName, ImagePurpose.Thumbnail, cancellationToken);

            var path = await _imageStorageService.UploadAsync(processedImage, cancellationToken);

            return path;
        }
    }
}
