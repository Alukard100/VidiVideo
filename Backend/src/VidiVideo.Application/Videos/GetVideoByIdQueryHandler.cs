using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;

namespace VidiVideo.Application.Videos
{
    public sealed class GetVideoByIdQueryHandler : IQueryHandler<GetVideoByIdQuery, VideoDto>
    {
        private readonly IVideoRepository _repo;
        public GetVideoByIdQueryHandler(IVideoRepository repo)
        {
            _repo = repo;
        }

        public async Task<VideoDto> HandleAsync(GetVideoByIdQuery query, CancellationToken cancellationToken)
        {
            var video = await _repo.GetVideoByIdAsync(query.videoId) ?? throw new NotFoundException("Video doesn't exist");

            return new VideoDto(
                video.Id,
                video.Caption,
                video.VideoUrl,
                video.ThumbnailUrl,
                video.Creator.DisplayName,
                video.Category.Name,
                video.IsPublished,
                video.Visibility,
                video.Likes.Count,
                video.Comments.Count,
                video.VideoHashtags
                    .Select(vh => vh.Hashtag.Name)
                    .ToList()
            );
        }
    }
}
