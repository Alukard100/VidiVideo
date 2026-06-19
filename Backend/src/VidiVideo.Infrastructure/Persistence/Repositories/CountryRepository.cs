using Microsoft.EntityFrameworkCore;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Domain.Entities;

namespace VidiVideo.Infrastructure.Persistence.Repositories
{
    public sealed class CountryRepository : ICountryRepository
    {
        private readonly VidiVideoDbContext _db;
        public CountryRepository(VidiVideoDbContext db)
        {
            _db = db;
        }
        public async Task AddAsync(Country country)
        {
            await _db.Countrys.AddAsync(country);
        }

        public async Task DeleteAsync(Guid id)
        {
            var country = await _db.Countrys.FirstOrDefaultAsync(c => c.Id == id);

            if (country != null)
                _db.Countrys.Remove(country);
        }

        public async Task<bool> ExistsByCodeAsync(string code)
            => await _db.Countrys.AnyAsync(c => c.Code == code);

        public async Task<bool> ExistsByCodeUpdateAsync(Guid id, string code)
            => await _db.Countrys.AnyAsync(c => id != c.Id && code == c.Code);

        public async Task<List<Country>> GetAllAsync()
        {
            return await _db.Countrys.OrderBy(c => c.Name).ToListAsync();
        }

        public Task<Country?> GetByIdAsync(Guid id)
            => _db.Countrys.FirstOrDefaultAsync(c => c.Id.Equals(id));
    }
}
