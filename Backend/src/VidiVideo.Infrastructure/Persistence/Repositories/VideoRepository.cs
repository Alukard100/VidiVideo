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

        public async Task CreateVideoAsync(Video video)
            => await _db.Videos.AddAsync(video);


        public Task DeleteVideoAsync(Guid videoId)
        {
            throw new NotImplementedException();
        }

        public async Task<Video?> GetVideoByIdAsync(Guid videoId)
        {
            return await _db.Videos
                .Include(v => v.Creator)
                .Include(v => v.Category)
                .FirstOrDefaultAsync(v => v.Id == videoId);
        }

        public Task<List<Video>> GetVideosAsync()
        {
            throw new NotImplementedException();
        }
    }
}
