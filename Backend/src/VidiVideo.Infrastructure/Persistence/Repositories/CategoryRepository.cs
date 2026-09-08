using Microsoft.EntityFrameworkCore;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Domain.Entities;

namespace VidiVideo.Infrastructure.Persistence.Repositories
{
    public sealed class CategoryRepository : ICategoryRepository
    {
        private readonly VidiVideoDbContext _db;

        public CategoryRepository(VidiVideoDbContext db)
        {
            _db = db;
        }

        public async Task<int> CountAsync(string? search, CancellationToken cancellationToken = default)
        {
            var query = _db.Categories.AsNoTracking().AsQueryable();

            if (!string.IsNullOrWhiteSpace(search))
            {
                var term = search.Trim();

                query = query.Where(x => x.Name.Contains(term));
            }

            return await query.CountAsync(cancellationToken);
        }

        public async Task CreateCategoryAsync(Category category)
            => await _db.Categories.AddAsync(category);

        public async Task DeleteCategoryAsync(Guid id)
        {
            var category = await _db.Categories.FirstOrDefaultAsync(c => c.Id == id);
            if (category != null)
                _db.Categories.Remove(category);
        }

        public async Task<bool> ExistByNameAsync(string name)
            => await _db.Categories.AnyAsync(c => c.Name == name);

        public async Task<bool> ExistsByIdAsync(Guid id)
            => await _db.Categories.AnyAsync(c => c.Id == id);

        public async Task<bool> ExistsByNameUpdateAsync(Guid id, string name)
            => await _db.Categories.AnyAsync(c => c.Id != id && c.Name == name);

        public async Task<List<Category>> GetAllCategoriesAsync(string? search, int page, int pageSize, CancellationToken cancellationToken = default)
        {
            var query = _db.Categories.AsNoTracking().AsQueryable();

            if (!string.IsNullOrWhiteSpace(search))
            {
                var term = search.Trim();

                query = query.Where(x => x.Name.Contains(term));
            }

            return await query
                .OrderBy(x => x.Name)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync(cancellationToken);
        }

        public async Task<Category?> GetByIdAsync(Guid id)
            => await _db.Categories.FirstOrDefaultAsync(c => c.Id == id);

        public async Task<bool> IsInUseAsync(Guid id, CancellationToken cancellationToken = default)
            => await _db.Videos.AnyAsync(x => x.CategoryId == id, cancellationToken);

    }
}
