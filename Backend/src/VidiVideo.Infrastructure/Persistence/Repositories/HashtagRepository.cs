using Microsoft.EntityFrameworkCore;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Domain.Entities;

namespace VidiVideo.Infrastructure.Persistence.Repositories
{
    public sealed class HashtagRepository : IHashtagRepository
    {
        private readonly VidiVideoDbContext _db;

        public HashtagRepository(VidiVideoDbContext db)
        {
            _db = db;
        }

        public async Task CreateHashtagAsync(Hashtag hashtag)
            => await _db.Hashtags.AddAsync(hashtag);

        public async Task DeleteHashtagAsync(Guid id)
        {
            var hashtag = await _db.Hashtags.FirstOrDefaultAsync(h => h.Id == id);
            if (hashtag != null)
                _db.Hashtags.Remove(hashtag);
        }

        public async Task<bool> ExistByNameAsync(string name)
            => await _db.Hashtags.AnyAsync(h => h.Name == name);

        public async Task<List<Hashtag>> GetAllHashtagsAsync()
            => await _db.Hashtags.OrderBy(h => h.Name).ToListAsync();

        public async Task<Hashtag?> GetByNameAsync(string name)
            => await _db.Hashtags.FirstOrDefaultAsync(h => h.Name == name);

        public async Task<Hashtag?> GetHashtagAsync(Guid id)
            => await _db.Hashtags.FirstOrDefaultAsync(h => h.Id == id);
    }
}
