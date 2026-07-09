using Microsoft.EntityFrameworkCore;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Domain.Entities;

namespace VidiVideo.Infrastructure.Persistence.Repositories
{
    public sealed class SearchHistoryRepository : ISearchHistoryRepository
    {
        private readonly VidiVideoDbContext _db;

        public SearchHistoryRepository(VidiVideoDbContext db)
        {
            _db = db;
        }
        public async Task AddAsync(SearchHistory history)
            => await _db.SearchHistories.AddAsync(history);

        public async Task ClearAsync(Guid userId)
        {
            var history = await _db.SearchHistories.Where(x => x.UserId == userId).ToListAsync();

            _db.SearchHistories.RemoveRange(history);
        }

        public async Task<int> CountAsync(Guid userId)
            => await _db.SearchHistories.CountAsync(x => x.UserId == userId);

        public async Task DeleteAsync(Guid id)
        {
            var entity = await GetByIdAsync(id);

            if (entity != null)
                _db.SearchHistories.Remove(entity);
        }

        public async Task<SearchHistory?> GetByIdAsync(Guid id)
            => await _db.SearchHistories.FirstOrDefaultAsync(x => x.Id == id);

        public async Task<List<SearchHistory>> GetUserHistoryAsync(Guid userId, int page = 1, int pageSize = 20)
        {
            return await _db.SearchHistories
                .Where(x => x.UserId == userId)
                .OrderByDescending(x => x.CreatedAtUtc)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();
        }
    }
}
