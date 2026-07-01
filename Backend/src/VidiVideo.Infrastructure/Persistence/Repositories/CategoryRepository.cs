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

        public async Task<List<Category>> GetAllCategoriesAsync()
            => await _db.Categories.OrderBy(c => c.Name).ToListAsync();

        public async Task<Category?> GetByIdAsync(Guid id)
            => await _db.Categories.FirstOrDefaultAsync(c => c.Id == id);
    }
}
