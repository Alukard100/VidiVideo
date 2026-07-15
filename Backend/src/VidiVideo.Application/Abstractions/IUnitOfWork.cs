public interface IUnitOfWork
{
    Task SaveChangesAsync(CancellationToken cancellationToken = default);
    Task BeginAsync();
    Task CommitAsync(CancellationToken cancellationToken = default);
    Task RollbackAsync();
}
