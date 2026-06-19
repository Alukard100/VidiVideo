using VidiVideo.Domain.Entities;

namespace VidiVideo.Application.Abstractions.Repositories
{
    public interface ICountryRepository
    {
        Task AddAsync(Country country);
        Task<Country?> GetByIdAsync(Guid id);
        Task<List<Country>> GetAllAsync();
        Task DeleteAsync(Guid id);
        Task<bool> ExistsByCodeAsync(string code);
        Task<bool> ExistsByCodeUpdateAsync(Guid id, string code);
    }
}
