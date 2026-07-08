using VidiVideo.Domain.Entities;

namespace VidiVideo.Application.Abstractions.Repositories;

public interface IVideoViewRepository
{
    Task CreateAsync(VideoView view);

    Task<VideoView?> GetByUserAndVideoAsync(Guid userId, Guid videoId);

    Task<List<VideoView>> GetVideoViewsAsync(Guid videoId);

    Task<int> CountViewsAsync(Guid videoId);
}
