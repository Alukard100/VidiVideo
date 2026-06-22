using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;
using VidiVideo.Domain.Entities;

namespace VidiVideo.Application.Videos
{
    public sealed class CreateVideoCommandHandler : ICommandHandler<CreateVideoCommand, Guid>
    {
        private readonly IVideoRepository _repo;
        private readonly IUnitOfWork _unitOfWork;

        public CreateVideoCommandHandler(IVideoRepository repo, IUnitOfWork unitOfWork)
        {
            _repo = repo;
            _unitOfWork = unitOfWork;
        }

        public async Task<Guid> HandleAsync(CreateVideoCommand command, CancellationToken cancellationToken)
        {
            if (string.IsNullOrWhiteSpace(command.VideoUrl))
                throw new ValidationException("VideoUrl is required");

            if (string.IsNullOrWhiteSpace(command.ThumbnailUrl))
                throw new ValidationException("ThumbnailUrl is required");

            var newVideo = new Video(command.CreatorId, command.CategoryId, command.Caption, command.VideoUrl, command.ThumbnailUrl, command.Visibility, command.IsPublished);

            await _repo.CreateVideoAsync(newVideo);

            await _unitOfWork.SaveChangesAsync(cancellationToken);

            return newVideo.Id;
        }
    }
}
