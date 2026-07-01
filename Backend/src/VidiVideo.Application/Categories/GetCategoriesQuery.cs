using VidiVideo.Application.Common;

namespace VidiVideo.Application.Categories;

public sealed record GetCategoriesQuery() : IQuery<List<CategoryDTO>>;
