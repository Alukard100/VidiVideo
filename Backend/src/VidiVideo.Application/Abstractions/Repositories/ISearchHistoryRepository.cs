using VidiVideo.Domain.Entities;

namespace VidiVideo.Application.Abstractions.Repositories;

public interface ISearchHistoryRepository
{
    Task AddAsync(SearchHistory history);

    Task<List<SearchHistory>> GetUserHistoryAsync(Guid userId, int page = 1, int pageSize = 20);
    Task<int> CountAsync(Guid userId);
    Task<SearchHistory?> GetByIdAsync(Guid id);
    Task DeleteAsync(Guid id);
    Task ClearAsync(Guid userId);
}
