using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;

namespace VidiVideo.Application.Videos
{
    public sealed class DeleteVideoCommandHandler : ICommandHandler<DeleteVideoCommand, bool>
    {
        private readonly IVideoRepository _repo;
        private readonly IUnitOfWork _unitOfWork;

        public DeleteVideoCommandHandler(IVideoRepository repo, IUnitOfWork unitOfWork)
        {
            _repo = repo;
            _unitOfWork = unitOfWork;
        }

        public async Task<bool> HandleAsync(DeleteVideoCommand command, CancellationToken cancellationToken)
        {
            var video = await _repo.GetVideoByIdAsync(command.Id) ?? throw new NotFoundException("Video doesn't exist");

            await _repo.DeleteVideoAsync(command.Id);

            await _unitOfWork.SaveChangesAsync(cancellationToken);

            return true;
        }
    }
}
