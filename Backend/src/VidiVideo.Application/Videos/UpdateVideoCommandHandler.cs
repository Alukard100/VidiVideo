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

        public UpdateVideoCommandHandler(IVideoRepository repo, IUnitOfWork unitOfWork, IHashtagRepository hashtagRepo)
        {
            _repo = repo;
            _unitOfWork = unitOfWork;
            _hashtagRepo = hashtagRepo;
        }

        public async Task<Guid> HandleAsync(UpdateVideoCommand command, CancellationToken cancellationToken)
        {
            var video = await _repo.GetVideoByIdAsync(command.videoId) ?? throw new NotFoundException("Video doesn't exist");

            video.Update(command.categoryId, command.caption, command.thumbnailUrl, command.visibility, command.isPublished);

            //Hashtag extraction
            var hashtagNames = HashtagParser.Extract(command.caption);

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
