using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;

namespace VidiVideo.Application.Categories
{
    public sealed class GetCategoriesQueryHandler : IQueryHandler<GetCategoriesQuery, PagedResult<CategoryDTO>>
    {
        private readonly ICategoryRepository _repo;

        public GetCategoriesQueryHandler(ICategoryRepository repo)
        {
            _repo = repo;
        }

        public async Task<PagedResult<CategoryDTO>> HandleAsync(GetCategoriesQuery query, CancellationToken cancellationToken)
        {

            var categories = await _repo.GetAllCategoriesAsync(query.Page, query.PageSize, cancellationToken);

            var count = await _repo.CountAsync(cancellationToken);

            var items = categories.Select(c => new CategoryDTO(c.Id, c.Name)).ToList();

            return new PagedResult<CategoryDTO>(items, query.Page, query.PageSize, count);

        }
    }
}
