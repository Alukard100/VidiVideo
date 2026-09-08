using VidiVideo.Domain.Entities;

namespace VidiVideo.Application.Abstractions.Repositories
{
    public interface ICountryRepository
    {
        Task AddAsync(Country country);
        Task<Country?> GetByIdAsync(Guid id);
        Task<List<Country>> GetAllAsync(string? search, int page, int pageSize, CancellationToken cancellationToken = default);
        Task<int> CountAsync(string? search, CancellationToken cancellationToken = default);
        Task DeleteAsync(Guid id);
        Task<bool> ExistsByCodeAsync(string code);
        Task<bool> ExistsByCodeUpdateAsync(Guid id, string code);
        Task<bool> ExistsByIdAsync(Guid id);
        Task<bool> IsInUseAsync(Guid id, CancellationToken cancellationToken = default);
    }
}
