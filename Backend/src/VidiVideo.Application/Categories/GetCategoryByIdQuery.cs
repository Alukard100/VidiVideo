using VidiVideo.Application.Common;

namespace VidiVideo.Application.Categories;

public sealed record GetCategoryByIdQuery(Guid Id) : IQuery<CategoryDTO>;
