using VidiVideo.Application.Followers;
using VidiVideo.Domain.Entities;

namespace VidiVideo.Application.Abstractions.Repositories;

public interface IFollowersRepository
{
    Task FollowAsync(Follow follow);
    Task HardUnfollowAsync(Follow follow);
    Task<bool> IsFollowingAsync(Guid current, Guid target);
    Task<Follow?> CheckExistingAsync(Guid current, Guid target);
    Task<List<UserFollowDto>> ViewFollowersAsync(Guid currentUserId, Guid targetId, int _page = 1, int _pageSize = 20);
    Task<List<UserFollowDto>> ViewFollowingAsync(Guid currentUserId, Guid targetId, int _page = 1, int _pageSize = 20);
    Task<int> CountFollowersAsync(Guid targetId);
    Task<int> CountFollowingAsync(Guid targetId);
    Task<HashSet<Guid>> GetFollowingCreatorIdsAsync(Guid userId);
}
