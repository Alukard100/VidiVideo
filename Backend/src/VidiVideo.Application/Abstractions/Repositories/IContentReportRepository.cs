using VidiVideo.Domain.Entities;

namespace VidiVideo.Application.Abstractions.Repositories;

public interface IContentReportRepository
{
    Task CreateAsync(ContentReport report);

    Task<ContentReport?> GetByIdAsync(Guid id);

    Task<bool> ExistsAsync(Guid id);

    Task DeleteAsync(ContentReport report);

    Task<int> CountAsync();

    Task<List<ContentReport>> GetPagedAsync(
        int _page = 1,
        int _pageSize = 20);
}
