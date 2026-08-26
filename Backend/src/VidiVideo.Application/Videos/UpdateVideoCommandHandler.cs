using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;
using VidiVideo.Application.Hashtags;
using VidiVideo.Application.Media;
using VidiVideo.Application.Messaging;
using VidiVideo.Domain.Entities;

namespace VidiVideo.Application.Videos
{
    public sealed class UpdateVideoCommandHandler : ICommandHandler<UpdateVideoCommand, Guid>
    {
        private readonly IVideoRepository _repo;
        private readonly IHashtagRepository _hashtagRepo;
        private readonly IUnitOfWork _unitOfWork;
        private readonly ICurrentUser _currentUser;
        private readonly IMessagePublisher _messagePublisher;
        private readonly IUserRepository _userRepository;

        public UpdateVideoCommandHandler(IVideoRepository repo, IUnitOfWork unitOfWork, IHashtagRepository hashtagRepo, ICurrentUser currentUser, IMessagePublisher messagePublisher, IUserRepository userRepository)
        {
            _repo = repo;
            _unitOfWork = unitOfWork;
            _hashtagRepo = hashtagRepo;
            _currentUser = currentUser;
            _messagePublisher = messagePublisher;
            _userRepository = userRepository;
        }

        public async Task<Guid> HandleAsync(UpdateVideoCommand command, CancellationToken cancellationToken)
        {
            var video = await _repo.GetVideoByIdAsync(command.VideoId, cancellationToken) ?? throw new NotFoundException("Video doesn't exist");

            var ownerId = _currentUser.UserId ?? throw new UnauthorizedException("Must be logged in");

            if (!await _repo.CheckOwnershipAsync(ownerId, command.VideoId, cancellationToken))
                throw new UnauthorizedException("You are not the owner of this video");

            if (command.Visibility == Domain.Enums.VideoVisibility.SubscribersOnly)
            {
                var creator = await _userRepository.GetByIdAsync(ownerId) ?? throw new NotFoundException("Creator doesn't exist.");

                if (!creator.HasConnectedPayPal)
                {
                    throw new ValidationException("Connect PayPal before publishing subscriber-only videos.");
                }
            }

            var oldThumbnailUrl = video.ThumbnailUrl;

            video.Update(command.CategoryId, command.Caption, command.ThumbnailUrl, command.Visibility, command.IsPublished);

            var hashtagNames = HashtagParser.Extract(command.Caption);

            List<Hashtag> hashtags = [];

            foreach (var name in hashtagNames)
            {
                var hashtag = await _hashtagRepo.GetByNameAsync(name);

                if (hashtag is null)
                {
                    hashtag = new Hashtag(name);

                    await _hashtagRepo.CreateHashtagAsync(hashtag);
                }

                hashtags.Add(hashtag);
            }

            video.ReplaceHashtags(hashtags);

            await _unitOfWork.SaveChangesAsync(cancellationToken);

            if (!string.IsNullOrWhiteSpace(oldThumbnailUrl) && !string.Equals(oldThumbnailUrl, command.ThumbnailUrl, StringComparison.OrdinalIgnoreCase))
            {
                await _messagePublisher.PublishAsync(QueueNames.ImageCleanup, new OldImageCleanupRequested(oldThumbnailUrl), cancellationToken);
            }

            return video.Id;
        }
    }
}
