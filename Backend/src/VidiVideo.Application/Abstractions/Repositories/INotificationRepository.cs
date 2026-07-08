using VidiVideo.Domain.Entities;

namespace VidiVideo.Application.Abstractions.Repositories;

public interface INotificationRepository
{
    Task CreateAsync(Notification notification);
    Task<Notification?> GetByIdAsync(Guid id);
    Task<List<Notification>> GetUserNotificationsAsync(Guid userId, int _page = 1, int _pageSize = 20);
    Task<int> CoutnAsync(Guid userId);

}
