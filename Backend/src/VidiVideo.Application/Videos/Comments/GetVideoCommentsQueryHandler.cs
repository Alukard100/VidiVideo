using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;

namespace VidiVideo.Application.Videos.Comments
{
    public sealed class GetVideoCommentsQueryHandler : IQueryHandler<GetVideoCommentsQuery, PagedResult<CommentDto>>
    {
        private readonly ICommentRepository _repo;
        private readonly IVideoRepository _videoRepository;

        public GetVideoCommentsQueryHandler(ICommentRepository repo, IVideoRepository videoRepository)
        {
            _repo = repo;
            _videoRepository = videoRepository;
        }

        public async Task<PagedResult<CommentDto>> HandleAsync(GetVideoCommentsQuery query, CancellationToken cancellationToken)
        {
            _ = await _videoRepository.GetVideoByIdAsync(query.videoId) ?? throw new NotFoundException("Video doesn't exist");

            var count = await _repo.CountVideoCommentsAsync(query.videoId);

            var comments = await _repo.GetVideoCommentsAsync(query.videoId, query.Page, query.PageSize);

            var items = comments.Select(c => new CommentDto(

                Id: c.Id,
                Content: c.Body,
                CreatedAtUtc: c.CreatedAtUtc,
                UpdatedAtUtc: c.UpdatedAtUtc,
                AuthorId: c.AuthorId,
                AuthorDisplayName: c.Author.DisplayName,
                AuthorAvatarUrl: c.Author.AvatarUrl
            )).ToList();

            return new PagedResult<CommentDto>(items, query.Page, query.PageSize, count);
        }
    }
}
