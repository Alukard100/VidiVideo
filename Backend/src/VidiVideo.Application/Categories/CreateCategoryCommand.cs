using VidiVideo.Application.Common;

namespace VidiVideo.Application.Categories;

public sealed record CreateCategoryCommand(string Name) : ICommand<Guid>;
