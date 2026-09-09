using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;
using VidiVideo.Domain.Entities;

namespace VidiVideo.Application.Categories
{
    public sealed class CreateCategoryCommandHandler : ICommandHandler<CreateCategoryCommand, Guid>
    {
        private readonly ICategoryRepository _repo;
        private readonly IUnitOfWork _unitOfWork;

        public CreateCategoryCommandHandler(ICategoryRepository repo, IUnitOfWork unitOfWork)
        {
            _repo = repo;
            _unitOfWork = unitOfWork;
        }

        public async Task<Guid> HandleAsync(CreateCategoryCommand command, CancellationToken cancellationToken)
        {
            if (string.IsNullOrWhiteSpace(command.Name))
                throw new ValidationException(
                    "Cant be empty");

            var name = command.Name.Trim();

            if (name.Length > 80)
                throw new ValidationException("Category name cannot exceed 80 characters");

            if (await _repo.ExistByNameAsync(name))
                throw new ConflictException("Category already exists");

            Category category = new(name);

            await _repo.CreateCategoryAsync(category);

            await _unitOfWork.SaveChangesAsync(cancellationToken);

            return category.Id;


        }
    }
}
