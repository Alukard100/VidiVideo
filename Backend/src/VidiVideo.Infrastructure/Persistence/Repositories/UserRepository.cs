using Microsoft.EntityFrameworkCore;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Domain.Entities;

namespace VidiVideo.Infrastructure.Persistence.Repositories
{
    public sealed class UserRepository : IUserRepository
    {
        private readonly VidiVideoDbContext _db;
        public UserRepository(VidiVideoDbContext db)
        {
            _db = db;
        }

        public async Task AddAsync(AppUser user)
        {
            _db.Add(user);
            await _db.SaveChangesAsync();
        }

        public async Task<bool> BothUsersExistsById(Guid first, Guid second)
            => await _db.Users.Where(u => u.Id == first || u.Id == second).CountAsync() == 2;

        public async Task<bool> ExistsByEmailAsync(string email)
            => await _db.Users.AnyAsync(u => u.Email == email);

        public async Task<bool> ExistsByIdAsync(Guid id)
            => await _db.Users.AnyAsync(u => u.Id == id);

        public async Task<bool> ExistsByUserNameAsync(string userName)
            => await _db.Users.AnyAsync(u => u.UserName == userName);
        public async Task<AppUser?> GetByEmailAsync(string email)
        {
            return await _db.Users.FirstOrDefaultAsync(u => u.Email == email);
        }

        public async Task<AppUser?> GetByIdAsync(Guid id)
            => await _db.Users.FirstOrDefaultAsync(u => u.Id == id);

        public async Task<AppUser?> GetByUserNameAsync(string username)
            => await _db.Users.FirstOrDefaultAsync(u => u.UserName == username);

        public async Task<AppUser?> GetProfileByIdAsync(Guid userId)
        {
            return await _db.Users
                .Include(x => x.Country)
                .Include(x => x.Videos.Where(v => !v.IsDeleted && v.IsPublished))
                .FirstOrDefaultAsync(x =>
                    x.Id == userId &&
                    !x.IsDeleted);
        }

        public async Task<int> FollowersCountAsync(Guid userId)
        {
            return await _db.Follows
                .CountAsync(x => x.CreatorId == userId);
        }

        public async Task<int> FollowingCountAsync(Guid userId)
        {
            return await _db.Follows
                .CountAsync(x => x.FollowerId == userId);
        }

        public async Task<bool> HasActiveSubscriptionAsync(Guid subscriberId, Guid creatorId)
        {
            return await _db.CreatorSubscriptions.AnyAsync(x =>
                x.SubscriberId == subscriberId &&
                x.CreatorId == creatorId &&
                x.IsActive &&
                x.EndsAtUtc != null &&
                x.EndsAtUtc > DateTime.UtcNow);
        }
    }
}
