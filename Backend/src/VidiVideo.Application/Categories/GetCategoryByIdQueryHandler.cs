using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;

namespace VidiVideo.Application.Categories
{
    public sealed class GetCategoryByIdQueryHandler : IQueryHandler<GetCategoryByIdQuery, CategoryDTO>
    {
        private readonly ICategoryRepository _repo;

        public GetCategoryByIdQueryHandler(ICategoryRepository repo)
        {
            _repo = repo;
        }

        public async Task<CategoryDTO> HandleAsync(GetCategoryByIdQuery query, CancellationToken cancellationToken)
        {
            var category = await _repo.GetByIdAsync(query.Id) ?? throw new NotFoundException("Category doesn't exist");

            CategoryDTO dto = new(Id: category.Id, Name: category.Name);

            return dto;
        }
    }
}
