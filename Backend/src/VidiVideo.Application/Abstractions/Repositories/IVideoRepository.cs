using VidiVideo.Domain.Entities;

namespace VidiVideo.Application.Abstractions.Repositories;

public interface IVideoRepository
{

    Task CreateVideoAsync(Video video, CancellationToken cancellationToken = default);
    Task DeleteVideoAsync(Guid videoId, CancellationToken cancellationToken = default);
    Task<Video?> GetVideoByIdAsync(Guid videoId, CancellationToken cancellationToken = default);
    Task<Video?> GetVideoForStreamingAsync(Guid videoId, CancellationToken cancellationToken = default);
    Task<int> CountAsync(string? search, Guid? category, List<string> hashtags, CancellationToken cancellationToken = default);
    Task<List<Video>> GetFilteredVideosAsync(string? search, Guid? category, List<string> hashtags, int _page = 1, int _pageSize = 10, CancellationToken cancellationToken = default);
    Task<bool> ExistsByIdAsync(Guid videoId, CancellationToken cancellationToken = default);
    Task<bool> CheckOwnershipAsync(Guid creatorId, Guid videoId, CancellationToken cancellationToken = default);
    Task<List<Video>> TopVideosAsync(DateTime? f = null, CancellationToken cancellationToken = default);
    Task<int> CountPublishedAsync(DateTime? from = null, CancellationToken cancellationToken = default);
    Task<int> CountPublicAsync(DateTime? from = null, CancellationToken cancellationToken = default);
    Task<int> CountSubscriberAsync(DateTime? from = null, CancellationToken cancellationToken = default);
    Task<int> CountVideosFromAsync(DateTime? from = null, CancellationToken cancellationToken = default);
    Task<List<Video>> GetRecommendationCandidatesAsync(
    Guid? userId,
    int limit = 300,
    CancellationToken cancellationToken = default);
    Task<List<Video>> GetFollowedFeedAsync(Guid userId, int _page = 1, int _pageSize = 10, CancellationToken cancellationToken = default);
    Task<int> CountFollowedFeedAsync(Guid userId, CancellationToken cancellationToken = default);
}
