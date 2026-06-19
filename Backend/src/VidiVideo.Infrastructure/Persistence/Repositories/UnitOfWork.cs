namespace VidiVideo.Infrastructure.Persistence.Repositories
{
    public sealed class UnitOfWork : IUnitOfWork
    {
        private readonly VidiVideoDbContext _db;

        public UnitOfWork(VidiVideoDbContext db)
        {
            _db = db;
        }

        public async Task SaveChangesAsync(
            CancellationToken cancellationToken = default)
        {
            await _db.SaveChangesAsync(cancellationToken);
        }
    }
}
