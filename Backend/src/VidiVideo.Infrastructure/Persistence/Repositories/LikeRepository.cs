using Microsoft.EntityFrameworkCore;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Domain.Entities;

namespace VidiVideo.Infrastructure.Persistence.Repositories
{
    public sealed class LikeRepository : ILikeRepository
    {
        private readonly VidiVideoDbContext _db;

        public LikeRepository(VidiVideoDbContext db)
        {
            _db = db;
        }

        public async Task<int> CountTotalLikesAsync(DateTime? f)
        {
            var query = _db.Likes.AsQueryable();
            if (f.HasValue)
                query = query.Where(x => x.CreatedAtUtc >= f.Value);
            return await query.CountAsync();

        }

        public async Task<bool> IsLikedByCurrentUser(Guid videoId, Guid userId)
            => await _db.Likes.AnyAsync(x => x.VideoId == videoId && x.UserId == userId);

        public async Task LikeVideoAsync(Like like)
            => await _db.Likes.AddAsync(like);

        public async Task<bool> UnlikeVideoAsync(Guid videId, Guid userId)
        {
            var existingLike = await _db.Likes.FirstOrDefaultAsync(x => x.VideoId == videId && x.UserId == userId);
            if (existingLike != null)
            {
                _db.Likes.Remove(existingLike);
                return true;
            }
            return false;
        }
    }
}
