using VidiVideo.Domain.Entities;

namespace VidiVideo.Application.Abstractions.Repositories
{
    public interface ICommentRepository
    {
        Task<Guid> CreateCommentAsync(Comment comment);
        Task DeleteCommentAsync(Guid commentId);
        Task<bool> ExistsByIdAsync(Guid commentId);
        Task<List<Comment>> GetVideoCommentsAsync(Guid videoId, int _page = 1, int _pageSize = 20);
        Task<int> CountVideoCommentsAsync(Guid videoId);
        Task<Comment?> GetCommentByIdAsync(Guid commentId);
        Task<bool> CheckOwnershipAsync(Guid userId, Guid commentId);
        Task<int> CountTotalCommentsAsync(DateTime? f = null);
    }
}
