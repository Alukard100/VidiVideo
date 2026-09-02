using VidiVideo.Application.Abstractions.DTOs;

namespace VidiVideo.Application.Abstractions
{
    public interface IImageStorageService
    {
        Task<string> UploadAsync(ProcessedImage processedImage, CancellationToken cancellationToken = default);
    }
}