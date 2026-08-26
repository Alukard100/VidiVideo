using Microsoft.EntityFrameworkCore;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Followers;
using VidiVideo.Domain.Entities;

namespace VidiVideo.Infrastructure.Persistence.Repositories
{
    public sealed class FollowersRepository : IFollowersRepository
    {
        private readonly VidiVideoDbContext _db;
        public FollowersRepository(VidiVideoDbContext db)
        {
            _db = db;
        }

        public async Task FollowAsync(Follow follow)
            => await _db.Follows.AddAsync(follow);

        public async Task<bool> IsFollowingAsync(Guid current, Guid target)
            => await _db.Follows.AnyAsync(x => x.FollowerId == current && x.CreatorId == target && !x.IsDeleted);

        public async Task<Follow?> CheckExistingAsync(Guid current, Guid target)
            => await _db.Follows.FirstOrDefaultAsync(x => x.FollowerId == current && x.CreatorId == target);

        public async Task<List<UserFollowDto>> ViewFollowersAsync(Guid currentUserId, Guid targetId, int _page = 1, int _pageSize = 20)
        {
            return await _db.Follows
                .Where(f => f.CreatorId == targetId && !f.IsDeleted)
                .Select(f => new UserFollowDto(
                    f.Follower.Id,
                    f.Follower.DisplayName,
                    f.Follower.AvatarUrl,
                    _db.Follows.Any(x =>
                        x.FollowerId == currentUserId &&
                        x.CreatorId == f.FollowerId &&
                        !x.IsDeleted)
                ))
                .Skip((_page - 1) * _pageSize)
                .Take(_pageSize)
                .ToListAsync();
        }

        public async Task<List<UserFollowDto>> ViewFollowingAsync(Guid currentUserId, Guid targetId, int _page = 1, int _pageSize = 20)
        {
            return await _db.Follows
                .Where(f => f.FollowerId == targetId && !f.IsDeleted)
                .Select(f => new UserFollowDto(
                    f.Creator.Id,
                    f.Creator.DisplayName,
                    f.Creator.AvatarUrl,
                    _db.Follows.Any(x =>
                        x.FollowerId == currentUserId &&
                        x.CreatorId == f.CreatorId &&
                        !x.IsDeleted)
                ))
                .Skip((_page - 1) * _pageSize)
                .Take(_pageSize)
                .ToListAsync();
        }

        public async Task<int> CountFollowersAsync(Guid targetId)
            => await _db.Follows.CountAsync(f => f.CreatorId == targetId);

        public async Task<int> CountFollowingAsync(Guid targetId)
            => await _db.Follows.CountAsync(f => f.FollowerId == targetId);

        public async Task<HashSet<Guid>> GetFollowingCreatorIdsAsync(Guid userId)
        {
            var ids = await _db.Follows
                .Where(f => f.FollowerId == userId)
                .Select(f => f.CreatorId)
                .ToListAsync();

            return ids.ToHashSet();
        }
    }
}
