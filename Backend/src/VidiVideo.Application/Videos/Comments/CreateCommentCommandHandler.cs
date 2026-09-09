using VidiVideo.Application.Abstractions;
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
        private readonly IVideoAccessService _videoAccessService;
        private readonly INotificationRepository _notificationRepository;
        private readonly IUnitOfWork _unitOfWork;
        private readonly ICurrentUser _currentUser;
        private readonly IChannelEmojiUsageValidator _emojiUsageValidator;
        public CreateCommentCommandHandler(ICommentRepository repo, IUserRepository userRepository, IVideoRepository videoRepository, IUnitOfWork unitOfWork, INotificationRepository notificationRepository, ICurrentUser currentUser, IChannelEmojiUsageValidator emojiUsageValidator, IVideoAccessService videoAccessService)
        {
            _repo = repo;
            _userRepository = userRepository;
            _videoRepository = videoRepository;
            _unitOfWork = unitOfWork;
            _notificationRepository = notificationRepository;
            _currentUser = currentUser;
            _emojiUsageValidator = emojiUsageValidator;
            _videoAccessService = videoAccessService;
        }

        public async Task<Guid> HandleAsync(CreateCommentCommand command, CancellationToken cancellationToken)
        {
            if (string.IsNullOrWhiteSpace(command.Content))
                throw new ValidationException("Can't post an empty comment");

            if (command.Content.Length > 500)
                throw new ValidationException("Comment cannot exceed 500 characters");

            var creatorId = _currentUser.UserId ?? throw new UnauthorizedException("Must be logged in");

            var video = await _videoRepository.GetVideoByIdAsync(command.VideoId, cancellationToken) ?? throw new NotFoundException("Video doesn't exist");

            var access = await _videoAccessService.GetAccessAsync(creatorId, video, cancellationToken);

            if (!access.IsVisible) throw new NotFoundException("Video doesn't exist");
            if (access.IsLocked) throw new ForbiddenException("An active subscription is required to access this video");

            await _emojiUsageValidator.ValidateAsync(creatorId, command.Content, cancellationToken);

            var currentUser = await _userRepository.GetByIdAsync(creatorId) ?? throw new UnauthorizedException("You must login");

            var comment = new Comment(command.VideoId, creatorId, command.Content);

            await _repo.CreateCommentAsync(comment);

            var notificationTitle = $"New comment from {currentUser.DisplayName}";
            if (notificationTitle.Length > 80)
                notificationTitle = notificationTitle[..80];

            var notification = new Notification(video.CreatorId, notificationTitle, $"New comment on \"{(video.Caption.Length <= 8 ? video.Caption : video.Caption.Substring(0, 8) + "...")}\"", NotificationType.Comment);

            await _notificationRepository.CreateAsync(notification);

            await _unitOfWork.SaveChangesAsync(cancellationToken);

            return comment.Id;
        }
    }
}
