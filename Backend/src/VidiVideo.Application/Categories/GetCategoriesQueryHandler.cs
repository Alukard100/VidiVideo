using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;

namespace VidiVideo.Application.Categories
{
    public sealed class GetCategoriesQueryHandler : IQueryHandler<GetCategoriesQuery, List<CategoryDTO>>
    {
        private readonly ICategoryRepository _repo;

        public GetCategoriesQueryHandler(ICategoryRepository repo)
        {
            _repo = repo;
        }

        public async Task<List<CategoryDTO>> HandleAsync(GetCategoriesQuery query, CancellationToken cancellationToken)
        {

            var categories = await _repo.GetAllCategoriesAsync();

            return categories
                .Select(c => new CategoryDTO(
                    c.Id, c.Name))
                .ToList();
        }
    }
}
