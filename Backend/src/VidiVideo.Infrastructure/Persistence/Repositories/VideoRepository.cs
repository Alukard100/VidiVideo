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

        public async Task<bool> CheckOwnershipAsync(Guid creatorId, Guid videoId, CancellationToken cancellationToken = default)
            => await _db.Videos.AnyAsync(x => x.Id == videoId && x.CreatorId == creatorId, cancellationToken);


        public async Task<int> CountAsync(string? search, Guid? category, List<string> hashtags, CancellationToken cancellationToken = default)
        {
            var query = _db.Videos
                .Where(q => q.IsPublished && !q.IsDeleted)
                .AsQueryable();
            if (!string.IsNullOrWhiteSpace(search))
                query = query.Where(q => q.Caption.Contains(search));

            if (hashtags.Any())
            {
                query = query.Where(q =>
                    q.VideoHashtags.Any(vh =>
                        hashtags.Contains(vh.Hashtag.Name)));
            }

            if (category.HasValue)
                query = query.Where(q => q.CategoryId == category.Value);

            return await query.CountAsync(cancellationToken);
        }

        public async Task<int> CountFollowedFeedAsync(Guid userId, CancellationToken cancellationToken = default)
        {
            var followedCreatorIds = _db.Follows
                .Where(f => f.FollowerId == userId)
                .Select(f => f.CreatorId);

            var subscribedCreatorIds = _db.CreatorSubscriptions
                .Where(s =>
                    s.SubscriberId == userId &&
                    s.IsActive &&
                    s.EndsAtUtc > DateTime.UtcNow)
                .Select(s => s.CreatorId);

            return await _db.Videos
                .Where(v =>
                    v.IsPublished &&
                    !v.IsDeleted &&
                    (
                        followedCreatorIds.Contains(v.CreatorId) ||
                        subscribedCreatorIds.Contains(v.CreatorId)
                    ))
                    .CountAsync(cancellationToken);
        }

        public async Task<int> CountPublicAsync(DateTime? f, CancellationToken cancellationToken = default)
        {
            var query = _db.Videos.AsQueryable();
            if (f.HasValue)
                query = query.Where(x => x.CreatedAtUtc >= f.Value);
            return await query.CountAsync(x => x.Visibility == Domain.Enums.VideoVisibility.Public, cancellationToken);

        }
        public async Task<int> CountPublishedAsync(DateTime? f, CancellationToken cancellationToken = default)
        {
            var query = _db.Videos.AsQueryable();
            if (f.HasValue)
                query = query.Where(x => x.CreatedAtUtc >= f.Value);
            return await query.CountAsync(x => x.IsPublished, cancellationToken);

        }
        public async Task<int> CountSubscriberAsync(DateTime? f, CancellationToken cancellationToken = default)
        {
            var query = _db.Videos.AsQueryable();
            if (f.HasValue)
                query = query.Where(x => x.CreatedAtUtc >= f.Value);
            return await query.CountAsync(x => x.Visibility == Domain.Enums.VideoVisibility.SubscribersOnly, cancellationToken);

        }

        public async Task<int> CountVideosFromAsync(DateTime? f = null, CancellationToken cancellationToken = default)
        {
            var query = _db.Videos.AsQueryable();
            if (f.HasValue)
                query = query.Where(x => x.CreatedAtUtc >= f.Value);
            return await query.CountAsync(cancellationToken);
        }

        public async Task CreateVideoAsync(Video video, CancellationToken cancellationToken = default)
            => await _db.Videos.AddAsync(video);


        public async Task DeleteVideoAsync(Guid videoId, CancellationToken cancellationToken = default)
        {
            var video = await _db.Videos.FirstOrDefaultAsync(x => x.Id == videoId, cancellationToken);
            if (video != null)
                _db.Videos.Remove(video);
        }

        public async Task<bool> ExistsByIdAsync(Guid videoId, CancellationToken cancellationToken = default)
            => await _db.Videos.AnyAsync(x => x.Id == videoId, cancellationToken);

        public async Task<List<Video>> GetFilteredVideosAsync(string? search, Guid? category, List<string> hashtags, int _page = 1, int _pageSize = 20, CancellationToken cancellationToken = default)
        {
            var query = _db.Videos
                    .Include(q => q.Creator)
                    .Include(q => q.Likes)
                    .Include(q => q.Comments)
                    .Include(q => q.VideoViews)
                    .Include(q => q.VideoHashtags)
                        .ThenInclude(vh => vh.Hashtag)
                    .Where(q => q.IsPublished && !q.IsDeleted)
                    .AsQueryable();

            if (!string.IsNullOrWhiteSpace(search))
                query = query.Where(q =>
                    q.Caption.Contains(search) ||
                    q.Creator.UserName.Contains(search) ||
                    q.Creator.DisplayName.Contains(search) ||
                    q.VideoHashtags.Any(vh => vh.Hashtag.Name.Contains(search)));

            if (category.HasValue)
                query = query.Where(q => q.CategoryId == category.Value);

            if (hashtags.Any())
            {
                query = query.Where(q =>
                    q.VideoHashtags.Any(vh =>
                        hashtags.Contains(vh.Hashtag.Name)));
            }

            query = query.OrderByDescending(q => q.CreatedAtUtc)
                    .Skip((_page - 1) * _pageSize)
                    .Take(_pageSize);

            return await query.AsSplitQuery().ToListAsync(cancellationToken);
        }

        public async Task<List<Video>> GetFollowedFeedAsync(Guid userId, int _page = 1, int _pageSize = 10, CancellationToken cancellationToken = default)
        {

            var followedCreatorIds = _db.Follows
                .Where(f => f.FollowerId == userId)
                .Select(f => f.CreatorId);

            var subscribedCreatorIds = _db.CreatorSubscriptions
                .Where(s =>
                    s.SubscriberId == userId &&
                    s.IsActive &&
                    s.EndsAtUtc > DateTime.UtcNow)
                .Select(s => s.CreatorId);

            return await _db.Videos
                .AsNoTracking()
                .Include(v => v.Creator)
                .Include(v => v.Category)
                .Include(v => v.VideoHashtags)
                    .ThenInclude(vh => vh.Hashtag)
                .Include(v => v.Likes)
                .Include(v => v.Comments)
                .Include(v => v.VideoViews)
                .Where(v =>
                    v.IsPublished &&
                    !v.IsDeleted &&
                    (
                        followedCreatorIds.Contains(v.CreatorId) ||
                        subscribedCreatorIds.Contains(v.CreatorId)
                    ))
                .OrderByDescending(v => v.CreatedAtUtc)
                .Skip((_page - 1) * _pageSize)
                    .Take(_pageSize)
                    .AsSplitQuery()
                    .ToListAsync(cancellationToken);
        }

        public async Task<List<Video>> GetRecommendationCandidatesAsync(Guid? userId, int limit = 300, CancellationToken cancellationToken = default)
        {
            var query = _db.Videos
                .AsNoTracking()
                .Include(v => v.Creator)
                    .ThenInclude(c => c.Country)
                .Include(v => v.Category)
                .Include(v => v.VideoHashtags)
                    .ThenInclude(vh => vh.Hashtag)
                .Include(v => v.Likes)
                .Include(v => v.Comments)
                .Include(v => v.VideoViews)
                .Where(v =>
                    v.IsPublished &&
                    !v.IsDeleted);

            if (userId.HasValue)
            {
                query = query.Where(v =>
                    v.CreatorId != userId.Value);
            }

            return await query
                .OrderByDescending(v => v.CreatedAtUtc)
                .Take(limit)
                .AsSplitQuery()
                .ToListAsync(cancellationToken);
        }

        public async Task<Video?> GetVideoByIdAsync(Guid videoId, CancellationToken cancellationToken = default)
        {
            return await _db.Videos
                .Include(v => v.Creator)
                .Include(v => v.Category)
                .Include(v => v.Likes)
                .Include(v => v.VideoViews)
                .Include(v => v.Comments)
                .Include(v => v.VideoHashtags)
                    .ThenInclude(vh => vh.Hashtag)
                .FirstOrDefaultAsync(v => v.Id == videoId, cancellationToken);
        }

        public async Task<Video?> GetVideoForStreamingAsync(Guid videoId, CancellationToken cancellationToken = default)
        {
            return await _db.Videos
                .AsNoTracking()
                .FirstOrDefaultAsync(v => v.Id == videoId, cancellationToken);
        }

        public async Task<List<Video>> TopVideosAsync(DateTime? f = null, CancellationToken cancellationToken = default)
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
                .ToListAsync(cancellationToken);
        }
    }
}
