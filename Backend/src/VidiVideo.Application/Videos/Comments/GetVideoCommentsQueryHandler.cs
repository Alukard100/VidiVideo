using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.ChannelEmojis;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;

namespace VidiVideo.Application.Videos.Comments
{
    public sealed class GetVideoCommentsQueryHandler : IQueryHandler<GetVideoCommentsQuery, PagedResult<CommentDto>>
    {
        private readonly ICommentRepository _repo;
        private readonly IVideoRepository _videoRepository;
        private readonly IChannelEmojiRepository _emojiRepository;

        public GetVideoCommentsQueryHandler(ICommentRepository repo, IVideoRepository videoRepository, IChannelEmojiRepository emojiRepository)
        {
            _repo = repo;
            _videoRepository = videoRepository;
            _emojiRepository = emojiRepository;
        }

        public async Task<PagedResult<CommentDto>> HandleAsync(GetVideoCommentsQuery query, CancellationToken cancellationToken)
        {
            _ = await _videoRepository.GetVideoByIdAsync(query.videoId, cancellationToken) ?? throw new NotFoundException("Video doesn't exist");

            var count = await _repo.CountVideoCommentsAsync(query.videoId);

            var comments = await _repo.GetVideoCommentsAsync(query.videoId, query.Page, query.PageSize);

            var allCodes = comments.SelectMany(c => EmojiParser.ExtractCodes(c.Body))
                .Distinct(StringComparer.OrdinalIgnoreCase)
                .ToArray();

            var emojis = await _emojiRepository.GetByCodesAsync(allCodes, cancellationToken);

            var emojiLookup = emojis.ToDictionary(
                x => x.Code,
                x => x.ImageUrl,
                StringComparer.OrdinalIgnoreCase);

            var items = comments.Select(c =>
            {
                var commentCodes = EmojiParser.ExtractCodes(c.Body);

                var commentEmojis = commentCodes.Where(code => emojiLookup.ContainsKey(code)).Select(code => new CommentEmojiDto(code, emojiLookup[code])).ToList();

                return new CommentDto(
                    Id: c.Id,
                    Content: c.Body,
                    CreatedAtUtc: c.CreatedAtUtc,
                    UpdatedAtUtc: c.UpdatedAtUtc,
                    AuthorId: c.AuthorId,
                    AuthorDisplayName: c.Author.DisplayName,
                    AuthorAvatarUrl: c.Author.AvatarUrl,
                    Emojis: commentEmojis);
            }).ToList();

            return new PagedResult<CommentDto>(items, query.Page, query.PageSize, count);
        }
    }
}
