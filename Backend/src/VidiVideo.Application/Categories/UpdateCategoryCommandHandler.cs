using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;
using VidiVideo.Domain.Entities;

namespace VidiVideo.Application.Categories
{
    public sealed class UpdateCategoryCommandHandler : ICommandHandler<UpdateCategoryCommand, CategoryDTO>
    {
        private readonly ICategoryRepository _repo;
        private readonly IUnitOfWork _unitOfWork;

        public UpdateCategoryCommandHandler(ICategoryRepository repo, IUnitOfWork unitOfWork)
        {
            _repo = repo;
            _unitOfWork = unitOfWork;
        }

        public async Task<CategoryDTO> HandleAsync(UpdateCategoryCommand command, CancellationToken cancellationToken)
        {

            if (string.IsNullOrWhiteSpace(command.Name))
                throw new ValidationException("Category name cannot be empty.");

            var name = command.Name.Trim();

            if (name.Length > 80)
                throw new ValidationException("Category name cannot exceed 80 characters");

            if (await _repo.ExistsByNameUpdateAsync(command.Id, name))
                throw new ConflictException("Category with that name already exists");

            Category current = await _repo.GetByIdAsync(command.Id) ?? throw new NotFoundException("Category doesn't exist");

            current.Update(name);

            await _unitOfWork.SaveChangesAsync(cancellationToken);

            return new CategoryDTO(current.Id, current.Name);
        }
    }
}
