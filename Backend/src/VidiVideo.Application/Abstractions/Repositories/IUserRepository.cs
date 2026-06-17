using VidiVideo.Domain.Entities;

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
    }
}
