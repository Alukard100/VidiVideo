using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;
using VidiVideo.Domain.Entities;
using VidiVideo.Domain.Enums;

namespace VidiVideo.Application.Videos.Comments
{
    public sealed class CreateCommentCommandHandler : ICommandHandler<CreateCommentCommand, Guid>
    {
        private readonly ICommentRepository _repo;
        private readonly IUserRepository _userRepository;
        private readonly IVideoRepository _videoRepository;
        private readonly INotificationRepository _notificationRepository;
        private readonly IUnitOfWork _unitOfWork;
        public CreateCommentCommandHandler(ICommentRepository repo, IUserRepository userRepository, IVideoRepository videoRepository, IUnitOfWork unitOfWork, INotificationRepository notificationRepository)
        {
            _repo = repo;
            _userRepository = userRepository;
            _videoRepository = videoRepository;
            _unitOfWork = unitOfWork;
            _notificationRepository = notificationRepository;
        }

        public async Task<Guid> HandleAsync(CreateCommentCommand command, CancellationToken cancellationToken)
        {
            if (string.IsNullOrWhiteSpace(command.Content))
                throw new ValidationException("Can't post an empty comment");

            var currentUser = await _userRepository.GetByIdAsync(command.UserID) ?? throw new UnauthorizedException("You must login");

            var video = await _videoRepository.GetVideoByIdAsync(command.VideoId) ?? throw new NotFoundException("Video doesn't exist");

            var comment = new Comment(command.VideoId, command.UserID, command.Content);

            await _repo.CreateCommentAsync(comment);

            var notification = new Notification(video.CreatorId, $"New comment from {currentUser.DisplayName}", $"New comment on \"{(video.Caption.Length <= 8 ? video.Caption : video.Caption.Substring(0, 8) + "...")}\"", NotificationType.Comment);

            await _notificationRepository.CreateAsync(notification);

            await _unitOfWork.SaveChangesAsync(cancellationToken);

            return comment.Id;
        }
    }
}
