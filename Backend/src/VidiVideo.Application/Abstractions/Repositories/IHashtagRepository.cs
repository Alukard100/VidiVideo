using VidiVideo.Domain.Entities;

namespace VidiVideo.Application.Abstractions.Repositories;

public interface IHashtagRepository
{
    Task CreateHashtagAsync(Hashtag hashtag);
    Task DeleteHashtagAsync(Guid id);
    Task<List<Hashtag>> GetAllHashtagsAsync(string? search, int page, int pageSize, CancellationToken cancellationToken = default);
    Task<int> CountAsync(string? search, CancellationToken cancellationToken = default);
    Task<Hashtag?> GetHashtagAsync(Guid id);
    Task<Hashtag?> GetByNameAsync(string name);
    Task<bool> ExistByNameAsync(string name);
}
