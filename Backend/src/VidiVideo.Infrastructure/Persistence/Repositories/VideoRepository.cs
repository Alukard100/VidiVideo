using Microsoft.EntityFrameworkCore;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Domain.Entities;

namespace VidiVideo.Infrastructure.Persistence.Repositories
{
    public sealed class VideoRepository : IVideoRepository
    {
        private readonly VidiVideoDbContext _db;

        public VideoRepository(VidiVideoDbContext db)
        {
            _db = db;
        }

        public async Task<bool> CheckOwnershipAsync(Guid creatorId, Guid videoId)
            => await _db.Videos.AnyAsync(x => x.Id == videoId && x.CreatorId == creatorId);


        public async Task<int> CountAsync(string? search, Guid? category, List<string> hashtags)
        {
            var query = _db.Videos.AsQueryable();
            if (!string.IsNullOrWhiteSpace(search))
                query = query.Where(q => q.Caption.Contains(search));

            if (hashtags.Any())
            {
                query = query.Where(q =>
                    q.VideoHashtags.Any(vh =>
                        hashtags.Contains(vh.Hashtag.Name)));
            }

            query = query.Where(q => q.IsDeleted == false);

            if (category.HasValue)
                query = query.Where(q => q.CategoryId == category.Value);

            return await query.CountAsync();
        }

        public async Task<int> CountPublicAsync(DateTime? f)
        {
            var query = _db.Videos.AsQueryable();
            if (f.HasValue)
                query = query.Where(x => x.CreatedAtUtc >= f.Value);
            return await query.CountAsync(x => x.Visibility == Domain.Enums.VideoVisibility.Public);

        }
        public async Task<int> CountPublishedAsync(DateTime? f)
        {
            var query = _db.Videos.AsQueryable();
            if (f.HasValue)
                query = query.Where(x => x.CreatedAtUtc >= f.Value);
            return await query.CountAsync(x => x.IsPublished);

        }
        public async Task<int> CountSubscriberAsync(DateTime? f)
        {
            var query = _db.Videos.AsQueryable();
            if (f.HasValue)
                query = query.Where(x => x.CreatedAtUtc >= f.Value);
            return await query.CountAsync(x => x.Visibility == Domain.Enums.VideoVisibility.SubscribersOnly);

        }

        public async Task<int> CountVideosFromAsync(DateTime? f = null)
        {
            var query = _db.Videos.AsQueryable();
            if (f.HasValue)
                query = query.Where(x => x.CreatedAtUtc >= f.Value);
            return await query.CountAsync();
        }

        public async Task CreateVideoAsync(Video video)
            => await _db.Videos.AddAsync(video);


        public async Task DeleteVideoAsync(Guid videoId)
        {
            var video = await _db.Videos.FirstOrDefaultAsync(x => x.Id == videoId);
            if (video != null)
                _db.Videos.Remove(video);
        }

        public async Task<bool> ExistsByIdAsync(Guid videoId)
            => await _db.Videos.AnyAsync(x => x.Id == videoId);

        public async Task<List<Video>> GetFilteredVideosAsync(string? search, Guid? category, List<string> hashtags, int _page = 1, int _pageSize = 20)
        {
            var query = _db.Videos.AsQueryable();

            query = query
                    .Include(q => q.Creator)
                    .Include(q => q.Likes)
                    .Include(q => q.Comments)
                    .Include(q => q.VideoHashtags)
                        .ThenInclude(vh => vh.Hashtag)
                    .AsQueryable();

            if (!string.IsNullOrWhiteSpace(search))
                query = query.Where(q => q.Caption.Contains(search));

            if (category.HasValue)
                query = query.Where(q => q.CategoryId == category.Value);

            if (hashtags.Any())
            {
                query = query.Where(q =>
                    q.VideoHashtags.Any(vh =>
                        hashtags.Contains(vh.Hashtag.Name)));
            }

            query = query.Where(q => q.IsDeleted == false);

            query = query.OrderByDescending(q => q.CreatedAtUtc)
                    .Skip((_page - 1) * _pageSize)
                    .Take(_pageSize);

            return await query.ToListAsync();
        }

        public async Task<Video?> GetVideoByIdAsync(Guid videoId)
        {
            return await _db.Videos
                .Include(v => v.Creator)
                .Include(v => v.Category)
                .Include(v => v.Likes)
                .Include(v => v.Comments)
                .Include(v => v.VideoHashtags)
                    .ThenInclude(vh => vh.Hashtag)
                .FirstOrDefaultAsync(v => v.Id == videoId);
        }

        public Task<List<Video>> GetVideosAsync()
        {
            throw new NotImplementedException();
        }

        public async Task<List<Video>> TopVideosAsync(DateTime? f = null)
        {
            var query = _db.Videos
                .Include(v => v.Creator)
                .Include(v => v.VideoViews)
                .Include(v => v.Likes)
                .Include(v => v.Comments)
                .AsQueryable();

            if (f.HasValue)
                query = query.Where(v => v.CreatedAtUtc >= f.Value);

            return await query
                .OrderByDescending(v => v.VideoViews.Count)
                .ThenByDescending(v => v.Likes.Count)
                .ThenByDescending(v => v.Comments.Count)
                .Take(30)
                .ToListAsync();
        }
    }
}
