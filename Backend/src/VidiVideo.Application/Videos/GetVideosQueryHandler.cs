using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;

namespace VidiVideo.Application.Videos
{
    public sealed class GetVideosQueryHandler : IQueryHandler<GetVideosQuery, PagedResult<VideoSummaryDto>>
    {
        private readonly IVideoRepository _repo;

        public GetVideosQueryHandler(IVideoRepository repo)
        {
            _repo = repo;
        }

        public async Task<PagedResult<VideoSummaryDto>> HandleAsync(GetVideosQuery query, CancellationToken cancellationToken)
        {
            var count = await _repo.CountAsync(query.Search, query.CategoryId, query.Hashtags);
            var videos = await _repo.GetFilteredVideosAsync(query.Search, query.CategoryId, query.Hashtags, query.Page, query.PageSize);

            var items = videos.Select(v => new VideoSummaryDto(
                Id: v.Id,
                Caption: v.Caption,
                CreatorDisplayName: v.Creator.UserName,
                ThumbnailUrl: v.ThumbnailUrl,
                Visibility: v.Visibility.ToString(),
                LikeCount: v.Likes.Count,
                CommentCount: v.Comments.Count
            )).ToList();

            return new PagedResult<VideoSummaryDto>(
                items, query.Page, query.PageSize, count);

        }
    }
}
