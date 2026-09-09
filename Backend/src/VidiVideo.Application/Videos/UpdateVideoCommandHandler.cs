using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;
using VidiVideo.Application.Hashtags;
using VidiVideo.Domain.Entities;
using VidiVideo.Domain.Enums;

namespace VidiVideo.Application.Videos
{
    public sealed class UpdateVideoCommandHandler : ICommandHandler<UpdateVideoCommand, Guid>
    {
        private readonly IVideoRepository _repo;
        private readonly IHashtagRepository _hashtagRepo;
        private readonly IUnitOfWork _unitOfWork;
        private readonly ICurrentUser _currentUser;
        private readonly IUserRepository _userRepository;
        private readonly ICategoryRepository _categoryRepository;

        public UpdateVideoCommandHandler(IVideoRepository repo, IUnitOfWork unitOfWork, IHashtagRepository hashtagRepo, ICurrentUser currentUser, IUserRepository userRepository, ICategoryRepository categoryRepository)
        {
            _repo = repo;
            _unitOfWork = unitOfWork;
            _hashtagRepo = hashtagRepo;
            _currentUser = currentUser;
            _userRepository = userRepository;
            _categoryRepository = categoryRepository;
        }

        public async Task<Guid> HandleAsync(UpdateVideoCommand command, CancellationToken cancellationToken)
        {
            var video = await _repo.GetVideoByIdAsync(command.VideoId, cancellationToken) ?? throw new NotFoundException("Video doesn't exist");

            var ownerId = _currentUser.UserId ?? throw new UnauthorizedException("Must be logged in");

            if (!await _repo.CheckOwnershipAsync(ownerId, command.VideoId, cancellationToken))
                throw new UnauthorizedException("You are not the owner of this video");

            if (string.IsNullOrWhiteSpace(command.Caption))
                throw new ValidationException("Caption is required");

            if (command.Caption.Length > 500)
                throw new ValidationException("Caption cannot exceed 500 characters");

            if (!Enum.IsDefined(command.Visibility))
                throw new ValidationException("Invalid video visibility");

            if (!await _categoryRepository.ExistsByIdAsync(command.CategoryId))
                throw new NotFoundException("Category doesn't exist");

            if (command.Visibility == Domain.Enums.VideoVisibility.SubscribersOnly)
            {
                var creator = await _userRepository.GetByIdAsync(ownerId) ?? throw new NotFoundException("Creator doesn't exist.");

                if (!creator.HasConnectedPayPal)
                {
                    throw new ValidationException("Connect PayPal before publishing subscriber-only videos.");
                }
            }

            var hashtagNames = HashtagParser.Extract(command.Caption);

            if (hashtagNames.Any(name => name.Length > 80))
                throw new ValidationException("Hashtag names cannot exceed 80 characters");

            video.Update(command.CategoryId, command.Caption, command.Visibility, command.IsPublished);

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

            return video.Id;
        }
    }
}
