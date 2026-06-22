using VidiVideo.Domain.Entities;

namespace VidiVideo.Application.Abstractions.Repositories;

public interface IVideoRepository
{

    Task CreateVideoAsync(Video video);
    Task DeleteVideoAsync(Guid videoId);
    Task<List<Video>> GetVideosAsync();
    Task<Video?> GetVideoByIdAsync(Guid videoId);
}
