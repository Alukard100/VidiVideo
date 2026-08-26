using VidiVideo.Application.Common;

namespace VidiVideo.Application.Categories;

public sealed record GetCategoriesQuery() : PagedRequest, IQuery<PagedResult<CategoryDTO>>;
