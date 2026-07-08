using Microsoft.EntityFrameworkCore;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Domain.Entities;

namespace VidiVideo.Infrastructure.Persistence.Repositories
{
    public sealed class NotificationRepository : INotificationRepository
    {
        private readonly VidiVideoDbContext _db;
        public NotificationRepository(VidiVideoDbContext db)
        {
            _db = db;
        }

        public async Task<int> CoutnAsync(Guid userId)
            => await _db.Notifications.CountAsync(x => x.UserId == userId);


        public async Task CreateAsync(Notification notification)
            => await _db.Notifications.AddAsync(notification);

        public async Task<Notification?> GetByIdAsync(Guid id)
            => await _db.Notifications.FirstOrDefaultAsync(x => x.Id == id);

        public async Task<List<Notification>> GetUserNotificationsAsync(Guid userId, int _page = 1, int _pageSize = 20)
            => await _db.Notifications.Where(x => x.Id == userId).OrderByDescending(x => x.CreatedAtUtc).Skip((_page - 1) * _pageSize).Take(_pageSize).ToListAsync();
    }
}
