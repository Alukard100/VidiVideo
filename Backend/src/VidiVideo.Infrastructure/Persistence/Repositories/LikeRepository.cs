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

        public async Task<Dictionary<Guid, double>> GetCollaborativeVideoScoreAsync(Guid userId)
        {
            var currentUserLikedVideoIds = await _db.Likes
                .Where(l => l.UserId == userId)
                .Select(l => l.VideoId)
                .ToListAsync();

            if (currentUserLikedVideoIds.Count == 0)
                return [];

            var similarUsers = await _db.Likes
                .Where(l =>
                    l.UserId != userId &&
                    currentUserLikedVideoIds.Contains(l.VideoId))
                .GroupBy(l => l.UserId)
                .Select(group => new
                {
                    UserId = group.Key,
                    SharedLikes = group.Count()
                })
                .ToListAsync();

            if (similarUsers.Count == 0)
                return [];

            var similarUserIds = similarUsers
                .Select(x => x.UserId)
                .ToList();

            var similarityLookup = similarUsers
                .ToDictionary(
                    x => x.UserId,
                    x => (double)x.SharedLikes);

            var recommendations = await _db.Likes
                .Where(l =>
                    similarUserIds.Contains(l.UserId) &&
                    !currentUserLikedVideoIds.Contains(l.VideoId))
                .Select(l => new
                {
                    l.UserId,
                    l.VideoId
                })
                .ToListAsync();

            return recommendations
                .GroupBy(x => x.VideoId)
                .ToDictionary(
                    group => group.Key,
                    group => group.Sum(
                        x => similarityLookup[x.UserId]));
        }

        public async Task<List<Video>> GetLikedVideosByUserAsync(Guid userId)
        {
            return await _db.Likes
            .Where(l => l.UserId == userId)
            .Select(l => l.Video)
            .Include(v => v.Category)
            .Include(v => v.VideoHashtags)
                .ThenInclude(vh => vh.Hashtag)
            .ToListAsync();
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
