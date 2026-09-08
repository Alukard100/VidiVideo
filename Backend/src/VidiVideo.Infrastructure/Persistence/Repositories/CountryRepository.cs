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

        public async Task<int> CountAsync(string? search, CancellationToken cancellationToken = default)
        {
            var query = _db.Countrys.AsNoTracking().AsQueryable();

            if (!string.IsNullOrWhiteSpace(search))
            {
                var term = search.Trim();

                query = query.Where(c => c.Name.Contains(term) || c.Code.Contains(term));
            }
            return await query.CountAsync(cancellationToken);
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

        public async Task<bool> ExistsByIdAsync(Guid id)
            => await _db.Countrys.AnyAsync(c => id == c.Id);

        public async Task<List<Country>> GetAllAsync(string? search, int page, int pageSize, CancellationToken cancellationToken = default)
        {
            var query = _db.Countrys.AsNoTracking().AsQueryable();

            if (!string.IsNullOrWhiteSpace(search))
            {
                var term = search.Trim();

                query = query.Where(c => c.Name.Contains(term) || c.Code.Contains(term));
            }

            return await query
                .OrderBy(c => c.Name)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync(cancellationToken);
        }

        public async Task<Country?> GetByIdAsync(Guid id)
            => await _db.Countrys.FirstOrDefaultAsync(c => c.Id.Equals(id));

        public async Task<bool> IsInUseAsync(Guid id, CancellationToken cancellationToken = default)
        {
            return await _db.Users.AnyAsync(u => u.CountryId == id, cancellationToken);
        }
    }
}
