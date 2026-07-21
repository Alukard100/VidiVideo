using Microsoft.EntityFrameworkCore;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Domain.Entities;

namespace VidiVideo.Infrastructure.Persistence.Repositories
{
    public sealed class VideoViewRepository : IVideoViewRepository
    {
        private readonly VidiVideoDbContext _db;
        public VideoViewRepository(VidiVideoDbContext db)
        {
            _db = db;
        }

        public async Task<int> CountTotalViewsAsync(DateTime? f)
        {
            var query = _db.VideoViews.AsQueryable();
            if (f.HasValue)
                query = query.Where(x => x.CreatedAtUtc >= f.Value);
            return await query.CountAsync();

        }

        public async Task<int> CountViewsAsync(Guid videoId)
            => await _db.VideoViews.CountAsync(x => x.VideoId == videoId);

        public async Task CreateAsync(VideoView view)
            => await _db.VideoViews.AddAsync(view);

        public async Task<VideoView?> GetByUserAndVideoAsync(Guid userId, Guid videoId)
            => await _db.VideoViews.FirstOrDefaultAsync(x => x.UserId == userId && x.VideoId == videoId);

        public async Task<List<VideoView>> GetVideoViewsAsync(Guid videoId)
            => await _db.VideoViews.Where(x => x.VideoId == videoId).ToListAsync();
    }
}
