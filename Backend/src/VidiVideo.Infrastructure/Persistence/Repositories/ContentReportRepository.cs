using Microsoft.EntityFrameworkCore;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Domain.Entities;

namespace VidiVideo.Infrastructure.Persistence.Repositories
{
    public sealed class ContentReportRepository : IContentReportRepository
    {
        private readonly VidiVideoDbContext _db;

        public ContentReportRepository(VidiVideoDbContext db)
        {
            _db = db;
        }

        public async Task<int> CountAsync()
            => await _db.ContentReports.CountAsync();
        public async Task CreateAsync(ContentReport report)
            => await _db.ContentReports.AddAsync(report);

        public Task DeleteAsync(ContentReport report)
        {
            throw new NotImplementedException();
        }

        public async Task<bool> ExistsAsync(Guid id)
            => await _db.ContentReports.AnyAsync(report => report.Id == id);

        public async Task<ContentReport?> GetByIdAsync(Guid id)
            => await _db.ContentReports.FirstOrDefaultAsync(x => x.Id == id);

        public async Task<List<ContentReport>> GetPagedAsync(int _page = 1, int _pageSize = 20)
        {
            var query = await _db.ContentReports.OrderByDescending(q => q.CreatedAtUtc).Skip((_page - 1) * _pageSize).Take(_pageSize).ToListAsync();

            return query;
        }
    }
}
