using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;
using VidiVideo.Application.Hashtags;
using VidiVideo.Domain.Entities;

namespace VidiVideo.Application.Videos
{
    public sealed class UpdateVideoCommandHandler : ICommandHandler<UpdateVideoCommand, Guid>
    {
        private readonly IVideoRepository _repo;
        private readonly IHashtagRepository _hashtagRepo;
        private readonly IUnitOfWork _unitOfWork;
        private readonly ICurrentUser _currentUser;

        public UpdateVideoCommandHandler(IVideoRepository repo, IUnitOfWork unitOfWork, IHashtagRepository hashtagRepo, ICurrentUser currentUser)
        {
            _repo = repo;
            _unitOfWork = unitOfWork;
            _hashtagRepo = hashtagRepo;
            _currentUser = currentUser;
        }

        public async Task<Guid> HandleAsync(UpdateVideoCommand command, CancellationToken cancellationToken)
        {
            var video = await _repo.GetVideoByIdAsync(command.VideoId) ?? throw new NotFoundException("Video doesn't exist");

            var ownerId = _currentUser.UserId ?? throw new UnauthorizedException("Must be logged in");

            if (!await _repo.CheckOwnershipAsync(ownerId, command.VideoId))
                throw new UnauthorizedException("You are not the owner of this video");

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

            return video.Id;
        }
    }
}
