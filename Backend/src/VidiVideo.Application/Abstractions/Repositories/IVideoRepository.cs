using VidiVideo.Domain.Entities;

namespace VidiVideo.Application.Abstractions.Repositories;

public interface IVideoRepository
{

    Task CreateVideoAsync(Video video);
    Task DeleteVideoAsync(Guid videoId);
    Task<List<Video>> GetVideosAsync();
    Task<Video?> GetVideoByIdAsync(Guid videoId);
    Task<int> CountAsync(string? search, Guid? category, List<string> hashtags);
    Task<List<Video>> GetFilteredVideosAsync(string? search, Guid? category, List<string> hashtags, int _page = 1, int _pageSize = 10);
}
