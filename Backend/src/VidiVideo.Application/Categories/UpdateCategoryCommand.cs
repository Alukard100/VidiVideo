using VidiVideo.Application.Common;

namespace VidiVideo.Application.Categories;

public sealed record UpdateCategoryCommand(Guid Id, string Name) : ICommand<CategoryDTO>;

