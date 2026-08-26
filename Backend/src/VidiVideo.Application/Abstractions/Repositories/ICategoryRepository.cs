using VidiVideo.Domain.Entities;

namespace VidiVideo.Application.Abstractions.Repositories;

public interface ICategoryRepository
{
    Task CreateCategoryAsync(Category category);
    Task<bool> ExistByNameAsync(string name);
    Task<List<Category>> GetAllCategoriesAsync(int page = 1, int pageSize = 30, CancellationToken cancellationToken = default);
    Task<int> CountAsync(CancellationToken cancellationToken = default);
    Task<Category?> GetByIdAsync(Guid id);
    Task DeleteCategoryAsync(Guid id);
    Task<bool> ExistsByNameUpdateAsync(Guid id, string name);
    Task<bool> ExistsByIdAsync(Guid id);

}
