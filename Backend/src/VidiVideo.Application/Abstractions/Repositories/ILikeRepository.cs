using VidiVideo.Domain.Entities;

namespace VidiVideo.Application.Abstractions.Repositories
{
    public interface ILikeRepository
    {
        Task LikeVideoAsync(Like like);
        Task<bool> UnlikeVideoAsync(Guid videId, Guid userId);
        Task<bool> IsLikedByCurrentUser(Guid videoId, Guid userId);
    }
}
