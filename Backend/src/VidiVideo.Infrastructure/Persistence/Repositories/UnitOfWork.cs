using Microsoft.EntityFrameworkCore.Storage;

namespace VidiVideo.Infrastructure.Persistence.Repositories
{
    public sealed class UnitOfWork : IUnitOfWork
    {
        private readonly VidiVideoDbContext _db;
        private IDbContextTransaction? _transaction;

        public UnitOfWork(VidiVideoDbContext db)
        {
            _db = db;
        }

        public async Task SaveChangesAsync(
            CancellationToken cancellationToken = default)
        {
            await _db.SaveChangesAsync(cancellationToken);
        }

        public async Task BeginAsync()
        {
            if (_transaction != null)
                throw new InvalidOperationException("Transaction already started");

            _transaction = await _db.Database.BeginTransactionAsync();
        }

        public async Task CommitAsync(CancellationToken cancellationToken = default)
        {
            if (_transaction is null)
                throw new InvalidOperationException("No transaction started");

            await _db.SaveChangesAsync(cancellationToken);

            await _transaction.CommitAsync();

            await _transaction.DisposeAsync();

            _transaction = null;
        }

        public async Task RollbackAsync()
        {
            if (_transaction is null)
                return;

            await _transaction.RollbackAsync();

            await _transaction.DisposeAsync();

            _transaction = null;
        }
    }
}
