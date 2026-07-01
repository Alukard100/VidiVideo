using VidiVideo.Application.Common;

namespace VidiVideo.Application.Categories;

public sealed record DeleteCategoryCommand(Guid Id) : ICommand<bool>;
