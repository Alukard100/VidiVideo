using Microsoft.EntityFrameworkCore;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Domain.Constants;
using VidiVideo.Domain.Entities;
using VidiVideo.Domain.Enums;

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
                .Include(x => x.Videos.Where(v => !v.IsDeleted))
                .FirstOrDefaultAsync(x =>
                    x.Id == userId &&
                    !x.IsDeleted);
        }

        public async Task<int> FollowersCountAsync(Guid userId)
        {
            return await _db.Follows
                .CountAsync(x => x.CreatorId == userId && !x.IsDeleted);
        }

        public async Task<int> FollowingCountAsync(Guid userId)
        {
            return await _db.Follows
                .CountAsync(x => x.FollowerId == userId && !x.IsDeleted);
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

        public async Task<List<AppUser>> GetFilteredUsersAsync(string? search, UserStatus? status, UserSortBy sortBy, SortDirection sortDirection, int _page = 1, int _pageSize = 20, CancellationToken cancellationToken = default)
        {
            var query = _db.Users.AsNoTracking()
                .Include(u => u.Videos.Where(v => !v.IsDeleted))
                .Include(u => u.Followers.Where(f => !f.IsDeleted))
                .Where(u => u.Role == AppRoles.User)
                .AsQueryable();

            if (!string.IsNullOrWhiteSpace(search))
            {
                query = query.Where(u => u.UserName.Contains(search) || u.DisplayName.Contains(search) || u.Email.Contains(search));
            }

            if (status.HasValue)
            {
                query = query.Where(u => u.Status == status.Value);
            }

            query = sortBy switch
            {
                UserSortBy.UserName => sortDirection == SortDirection.Ascending
                    ? query.OrderBy(u => u.UserName)
                    : query.OrderByDescending(u => u.UserName),

                UserSortBy.RegistrationDate => sortDirection == SortDirection.Ascending
                    ? query.OrderBy(u => u.CreatedAtUtc)
                    : query.OrderByDescending(u => u.CreatedAtUtc),

                UserSortBy.VideoCount => sortDirection == SortDirection.Ascending
                    ? query.OrderBy(u => u.Videos.Count(v => !v.IsDeleted))
                    : query.OrderByDescending(u => u.Videos.Count(v => !v.IsDeleted)),

                UserSortBy.FollowersCount => sortDirection == SortDirection.Ascending
                    ? query.OrderBy(u => u.Followers.Count(f => !f.IsDeleted))
                    : query.OrderByDescending(u => u.Followers.Count(f => !f.IsDeleted)),

                UserSortBy.Status => sortDirection == SortDirection.Ascending
                    ? query.OrderBy(u => u.Status)
                    : query.OrderByDescending(u => u.Status),

                _ => query.OrderByDescending(u => u.CreatedAtUtc)
            };

            query = query
                .Skip((_page - 1) * _pageSize)
                .Take(_pageSize);

            return await query.AsSplitQuery().ToListAsync(cancellationToken);

        }

        public async Task<int> CountFilteredUsersAsync(string? search, UserStatus? status, CancellationToken cancellationToken = default)
        {
            var query = _db.Users
                .AsNoTracking()
                .AsQueryable()
                .Where(u => u.Role == AppRoles.User);

            if (!string.IsNullOrEmpty(search))
            {
                query = query.Where(u =>
                    u.UserName.Contains(search) ||
                    u.DisplayName.Contains(search) ||
                    u.Email.Contains(search));
            }

            if (status.HasValue)
                query = query.Where(u => u.Status == status.Value);

            return await query.CountAsync(cancellationToken);
        }

        public async Task DeleteAsync(Guid id, CancellationToken cancellationToken = default)
        {
            var user = await _db.Users.FirstOrDefaultAsync(u => u.Id == id, cancellationToken);

            if (user != null)
            {
                _db.Users.Remove(user);
            }
        }

        public async Task<List<AppUser>> GetStaffAsync(string? search, string? role, int page, int pageSize, CancellationToken cancellationToken = default)
        {
            var staff = await BuildStaffQuery(search, role)
                .OrderBy(u =>
                    u.Role == AppRoles.SuperAdmin ? 0 :
                    u.Role == AppRoles.Admin ? 1 :
                    u.Role == AppRoles.Moderator ? 2 :
                    3)
                .ThenBy(u => u.CreatedAtUtc)
                .ThenBy(u => u.Id)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync(cancellationToken);

            return staff;
        }

        public async Task<int> CountStaffAsync(string? search, string? role, CancellationToken cancellationToken = default)
        {
            return await BuildStaffQuery(search, role).CountAsync(cancellationToken);
        }

        private IQueryable<AppUser> BuildStaffQuery(string? search, string? role)
        {
            var query = _db.Users
                .AsNoTracking()
                .Where(u => u.Role != AppRoles.User)
                .AsQueryable();

            if (!string.IsNullOrWhiteSpace(search))
            {
                var term = search.Trim();
                query = query.Where(u =>
                    u.UserName.Contains(term) ||
                    u.DisplayName.Contains(term) ||
                    u.Email.Contains(term));
            }

            if (!string.IsNullOrWhiteSpace(role))
                query = query.Where(u => u.Role == role);

            return query;
        }
    }
}
