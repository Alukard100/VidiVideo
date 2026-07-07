using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;
using VidiVideo.Domain.Entities;

namespace VidiVideo.Application.Videos.Comments
{
    public sealed class CreateCommentCommandHandler : ICommandHandler<CreateCommentCommand, Guid>
    {
        private readonly ICommentRepository _repo;
        private readonly IUserRepository _userRepository;
        private readonly IVideoRepository _videoRepository;
        private readonly IUnitOfWork _unitOfWork;
        public CreateCommentCommandHandler(ICommentRepository repo, IUserRepository userRepository, IVideoRepository videoRepository, IUnitOfWork unitOfWork)
        {
            _repo = repo;
            _userRepository = userRepository;
            _videoRepository = videoRepository;
            _unitOfWork = unitOfWork;
        }

        public async Task<Guid> HandleAsync(CreateCommentCommand command, CancellationToken cancellationToken)
        {
            if (string.IsNullOrWhiteSpace(command.Content))
                throw new ValidationException("Can't post an empty comment");

            if (await _userRepository.ExistsByIdAsync(command.UserID))
                throw new UnauthorizedException("You must login");

            _ = await _videoRepository.GetVideoByIdAsync(command.VideoId) ?? throw new NotFoundException("Video doesn't exist");

            var comment = new Comment(command.VideoId, command.UserID, command.Content);

            await _repo.CreateCommentAsync(comment);

            await _unitOfWork.SaveChangesAsync();

            return comment.Id;
        }
    }
}
