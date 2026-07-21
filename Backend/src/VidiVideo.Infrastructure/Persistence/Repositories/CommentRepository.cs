using Microsoft.EntityFrameworkCore;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Domain.Entities;

namespace VidiVideo.Infrastructure.Persistence.Repositories
{
    public sealed class CommentRepository : ICommentRepository
    {
        private readonly VidiVideoDbContext _db;

        public CommentRepository(VidiVideoDbContext db)
        {
            _db = db;
        }

        public async Task<bool> CheckOwnershipAsync(Guid userId, Guid commentId)
            => await _db.Comments.AnyAsync(x => x.Id == commentId && x.AuthorId == userId);

        public async Task<int> CountTotalCommentsAsync(DateTime? f)
        {
            var query = _db.Comments.AsQueryable();
            if (f.HasValue)
                query = query.Where(x => x.CreatedAtUtc >= f.Value);
            return await query.CountAsync();

        }

        public async Task<int> CountVideoCommentsAsync(Guid videoId)
            => await _db.Comments.CountAsync(c => c.VideoId == videoId);


        public async Task<Guid> CreateCommentAsync(Comment comment)
        {
            await _db.Comments.AddAsync(comment);
            return comment.Id;
        }

        public async Task DeleteCommentAsync(Guid commentId)
        {
            var comment = await _db.Comments.FirstOrDefaultAsync(x => x.Id == commentId);

            if (comment != null)
                _db.Comments.Remove(comment);

        }

        public async Task<bool> ExistsByIdAsync(Guid commentId)
            => await _db.Comments.AnyAsync(x => x.Id == commentId);

        public async Task<Comment?> GetCommentByIdAsync(Guid commentId)
            => await _db.Comments.FirstOrDefaultAsync(c => c.Id == commentId);


        public async Task<List<Comment>> GetVideoCommentsAsync(Guid videoId, int _page = 1, int _pageSize = 20)
        {
            var comments = await _db.Comments
                .Where(c => c.VideoId == videoId)
                .OrderByDescending(c => c.CreatedAtUtc)
                .Skip((_page - 1) * _pageSize)
                .Take(_pageSize)
                .ToListAsync();

            return comments;
        }
    }
}
