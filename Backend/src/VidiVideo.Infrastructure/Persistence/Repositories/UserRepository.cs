using Microsoft.EntityFrameworkCore;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Domain.Entities;

namespace VidiVideo.Infrastructure.Persistence.Repositories
{
    public sealed class UserRepository : IUserRepository
    {
        private readonly VidiVideoDbContext _db;
        public UserRepository(VidiVideoDbContext db)
        {
            _db = db;
        }

        public async Task AddAsync(AppUser user)
        {
            _db.Add(user);
            await _db.SaveChangesAsync();
        }

        public async Task<bool> ExistsByEmailAsync(string email)
            => await _db.Users.AnyAsync(u => u.Email == email);

        public async Task<bool> ExistsByIdAsync(Guid id)
            => await _db.Users.AnyAsync(u => u.Id == id);

        public async Task<bool> ExistsByUserNameAsync(string userName)
            => await _db.Users.AnyAsync(u => u.UserName == userName);
        public async Task<AppUser?> GetByEmailAsync(string email)
        {
            return await _db.Users.FirstOrDefaultAsync(u => u.Email == email);
        }

        public async Task<AppUser?> GetByIdAsync(Guid id)
            => await _db.Users.FirstOrDefaultAsync(u => u.Id == id);

        public async Task<AppUser?> GetByUserNameAsync(string username)
            => await _db.Users.FirstOrDefaultAsync(u => u.UserName == username);
    }
}
