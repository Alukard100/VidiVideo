using VidiVideo.Application.Abstractions.DTOs;
using VidiVideo.Domain.Entities;

namespace VidiVideo.Application.Abstractions;

public interface IVideoAccessService
{
    Task<VideoAccessResult> GetAccessAsync(
        Guid? userId,
        Video video,
        CancellationToken cancellationToken = default);
}
