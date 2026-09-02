using VidiVideo.Application.Abstractions.DTOs;
using VidiVideo.Domain.Enums;

namespace VidiVideo.Application.Abstractions;

public interface IImageProcessor
{
    Task<ProcessedImage> ProcessAsync(Stream stream, string fileName, ImagePurpose imagePurpose, CancellationToken cancellationToken = default);
}
