using VidiVideo.Domain.Entities;

namespace VidiVideo.Application.Abstractions.Repositories;

public interface IVideoRepository
{

    Task CreateVideoAsync(Video video);
    Task DeleteVideoAsync(Guid videoId);
    Task<List<Video>> GetVideosAsync();
    Task<Video?> GetVideoByIdAsync(Guid videoId);
    Task<Video?> GetVideoForStreamingAsync(Guid videoId);
    Task<int> CountAsync(string? search, Guid? category, List<string> hashtags);
    Task<List<Video>> GetFilteredVideosAsync(string? search, Guid? category, List<string> hashtags, int _page = 1, int _pageSize = 10);
    Task<bool> ExistsByIdAsync(Guid videoId);
    Task<bool> CheckOwnershipAsync(Guid creatorId, Guid videoId);
    Task<List<Video>> TopVideosAsync(DateTime? f = null);
    Task<int> CountPublishedAsync(DateTime? from = null);
    Task<int> CountPublicAsync(DateTime? from = null);
    Task<int> CountSubscriberAsync(DateTime? from = null);
    Task<int> CountVideosFromAsync(DateTime? from = null);
    Task<List<Video>> GetRecommendationCandidatesAsync(
    Guid? userId,
    int limit = 300);
    Task<List<Video>> GetFollowedFeedAsync(Guid userId, int _page = 1, int _pageSize = 10);
    Task<int> CountFollowedFeedAsync(Guid userId);
}
