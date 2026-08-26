using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;
using VidiVideo.Application.Hashtags;
using VidiVideo.Domain.Entities;

namespace VidiVideo.Application.Videos
{
    public sealed class CreateVideoCommandHandler : ICommandHandler<CreateVideoCommand, Guid>
    {
        private readonly IVideoRepository _repo;
        private readonly ICategoryRepository _categoryRepo;
        private readonly IHashtagRepository _hashtagRepo;
        private readonly IUserRepository _userRepo;
        private readonly IUnitOfWork _unitOfWork;
        private readonly ICurrentUser _currentUser;

        public CreateVideoCommandHandler(IVideoRepository repo, IUnitOfWork unitOfWork, ICategoryRepository categoryRepo, IHashtagRepository hashtagRepo, IUserRepository userRepository, ICurrentUser currentUser)
        {
            _repo = repo;
            _unitOfWork = unitOfWork;
            _categoryRepo = categoryRepo;
            _hashtagRepo = hashtagRepo;
            _userRepo = userRepository;
            _currentUser = currentUser;
        }

        public async Task<Guid> HandleAsync(CreateVideoCommand command, CancellationToken cancellationToken)
        {
            if (string.IsNullOrWhiteSpace(command.VideoUrl))
                throw new ValidationException("VideoUrl is required");

            if (string.IsNullOrWhiteSpace(command.ThumbnailUrl))
                throw new ValidationException("ThumbnailUrl is required");

            var creatorId = _currentUser.UserId ?? throw new UnauthorizedException("Must be logged in");

            if (command.Visibility == Domain.Enums.VideoVisibility.SubscribersOnly)
            {
                var creator = await _userRepo.GetByIdAsync(creatorId) ?? throw new NotFoundException("Creator doesn't exist");

                if (!creator.HasConnectedPayPal)
                {
                    throw new ValidationException("Connect PayPal before publishing subscriber-only videos.");
                }
            }

            if (!await _categoryRepo.ExistsByIdAsync(command.CategoryId))
                throw new NotFoundException($"{command.CategoryId} not found");

            var hashtagNames = HashtagParser.Extract(command.Caption);

            var videoHashtags = new List<VideoHashtag>();

            foreach (var hashtagName in hashtagNames)
            {
                var hashtag = await _hashtagRepo.GetByNameAsync(hashtagName);

                if (hashtag is null)
                {
                    hashtag = new Hashtag(hashtagName);

                    await _hashtagRepo.CreateHashtagAsync(hashtag);
                }

                videoHashtags.Add(
                    new VideoHashtag(hashtag));
            }

            var newVideo = new Video(creatorId, command.CategoryId, command.Caption, command.VideoUrl, command.ThumbnailUrl, command.Visibility, command.IsPublished);

            newVideo.AddHashtags(videoHashtags);

            await _repo.CreateVideoAsync(newVideo, cancellationToken);

            await _unitOfWork.SaveChangesAsync(cancellationToken);

            return newVideo.Id;
        }
    }
}
