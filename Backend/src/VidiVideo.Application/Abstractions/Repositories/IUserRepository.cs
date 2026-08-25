using VidiVideo.Domain.Entities;
using VidiVideo.Domain.Enums;

namespace VidiVideo.Application.Abstractions.Repositories
{
    public interface IUserRepository
    {
        Task<bool> ExistsByEmailAsync(string email);
        Task<bool> ExistsByUserNameAsync(string userName);
        Task AddAsync(AppUser user);
        Task<AppUser?> GetByEmailAsync(string email);
        Task<AppUser?> GetByIdAsync(Guid id);
        Task<AppUser?> GetByUserNameAsync(string username);
        Task<bool> ExistsByIdAsync(Guid id);
        Task<bool> BothUsersExistsById(Guid first, Guid second);
        Task<AppUser?> GetProfileByIdAsync(Guid userId);
        Task<int> FollowersCountAsync(Guid userId);
        Task<int> FollowingCountAsync(Guid userId);
        Task<bool> HasActiveSubscriptionAsync(Guid subscriberId, Guid creatorId);
        Task<List<AppUser>> GetFilteredUsersAsync(string? search, UserStatus? status, UserSortBy sortBy, SortDirection sortDirection, int _page = 1, int _pageSize = 20, CancellationToken cancellationToken = default);
        Task<int> CountFilteredUsersAsync(string? search, UserStatus? status, CancellationToken cancellationToken = default);
        Task<List<AppUser>> GetStaffAsync(CancellationToken cancellationToken = default);
        Task DeleteAsync(Guid id, CancellationToken cancellationToken = default);
    }
}
