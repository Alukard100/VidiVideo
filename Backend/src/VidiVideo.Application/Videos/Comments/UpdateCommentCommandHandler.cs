using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;
using VidiVideo.Domain.Constants;

namespace VidiVideo.Application.Videos.Comments
{
    public sealed class UpdateCommentCommandHandler : ICommandHandler<UpdateCommentCommand, Guid>
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly ICommentRepository _repo;
        private readonly ICurrentUser _currentUser;
        private readonly IChannelEmojiUsageValidator _emojiUsageValidator;
        private readonly IVideoAccessService _videoAccessService;
        private readonly IVideoRepository _videoRepository;
        public UpdateCommentCommandHandler(IUnitOfWork unitOfWork, ICommentRepository repo, ICurrentUser currentUser, IChannelEmojiUsageValidator emojiUsageValidator, IVideoAccessService videoAccessService, IVideoRepository videoRepository)
        {
            _unitOfWork = unitOfWork;
            _repo = repo;
            _currentUser = currentUser;
            _emojiUsageValidator = emojiUsageValidator;
            _videoAccessService = videoAccessService;
            _videoRepository = videoRepository;
        }

        public async Task<Guid> HandleAsync(UpdateCommentCommand command, CancellationToken cancellationToken)
        {
            if (string.IsNullOrWhiteSpace(command.Content))
                throw new ValidationException("New comment can't be empty");

            var comment = await _repo.GetCommentByIdAsync(command.Id) ?? throw new NotFoundException("Comment doesn't exist");
            var video = await _videoRepository.GetVideoByIdAsync(comment.VideoId) ?? throw new NotFoundException("Video doesn't exist");

            var creatorId = _currentUser.UserId ?? throw new UnauthorizedException("Must be logged in");

            if (!_currentUser.IsInRole(AppRoles.Admin))
            {
                if (!await _repo.CheckOwnershipAsync(creatorId, command.Id))
                    throw new UnauthorizedException("This comment isn't yours");

                var access = await _videoAccessService.GetAccessAsync(creatorId, video, cancellationToken);
                if (!access.IsVisible) throw new NotFoundException("Video doesn't exist");
                if (access.IsLocked) throw new ForbiddenException("An active subscription is required to access this video");
            }

            await _emojiUsageValidator.ValidateAsync(creatorId, command.Content, cancellationToken);

            comment.UpdateComment(command.Content);

            await _unitOfWork.SaveChangesAsync(cancellationToken);

            return command.Id;
        }
    }
}
