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

        public CreateVideoCommandHandler(IVideoRepository repo, IUnitOfWork unitOfWork, ICategoryRepository categoryRepo, IHashtagRepository hashtagRepo, IUserRepository userRepository)
        {
            _repo = repo;
            _unitOfWork = unitOfWork;
            _categoryRepo = categoryRepo;
            _hashtagRepo = hashtagRepo;
            _userRepo = userRepository;
        }

        public async Task<Guid> HandleAsync(CreateVideoCommand command, CancellationToken cancellationToken)
        {
            if (string.IsNullOrWhiteSpace(command.VideoUrl))
                throw new ValidationException("VideoUrl is required");

            if (string.IsNullOrWhiteSpace(command.ThumbnailUrl))
                throw new ValidationException("ThumbnailUrl is required");

            if (!await _categoryRepo.ExistsByIdAsync(command.CategoryId))
                throw new NotFoundException($"{command.CategoryId} not found");

            if (!await _userRepo.ExistsByIdAsync(command.CreatorId))
                throw new NotFoundException($"{command.CreatorId} not found");

            //Hashtag extraction
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

            var newVideo = new Video(command.CreatorId, command.CategoryId, command.Caption, command.VideoUrl, command.ThumbnailUrl, command.Visibility, command.IsPublished);

            newVideo.AddHashtags(videoHashtags);

            await _repo.CreateVideoAsync(newVideo);

            await _unitOfWork.SaveChangesAsync(cancellationToken);

            return newVideo.Id;
        }
    }
}
