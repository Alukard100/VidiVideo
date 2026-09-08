using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;

namespace VidiVideo.Application.Categories
{
    public sealed class DeleteCategoryCommandHandler : ICommandHandler<DeleteCategoryCommand, bool>
    {
        private readonly ICategoryRepository _repo;
        private readonly IUnitOfWork _unitOfWork;

        public DeleteCategoryCommandHandler(ICategoryRepository repo, IUnitOfWork unitOfWork)
        {
            _repo = repo;
            _unitOfWork = unitOfWork;
        }

        public async Task<bool> HandleAsync(DeleteCategoryCommand command, CancellationToken cancellationToken)
        {
            _ = await _repo.GetByIdAsync(command.Id) ?? throw new NotFoundException("Hashtag doesn't exist");

            if (await _repo.IsInUseAsync(command.Id, cancellationToken)) throw new ConflictException("Category cannot be deleted because it is currently used by one or more videos.");

            await _repo.DeleteCategoryAsync(command.Id);

            await _unitOfWork.SaveChangesAsync(cancellationToken);

            return true;
        }
    }
}
