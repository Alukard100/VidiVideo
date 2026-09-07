using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.ChannelEmojis;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;

namespace VidiVideo.Application.ContentReports;

public sealed class GetContentReportDetailQueryHandler
    : IQueryHandler<
        GetContentReportDetailQuery,
        ContentReportDetailDto>
{
    private readonly IContentReportRepository _repo;
    private readonly IChannelEmojiRepository _emojiRepository;

    public GetContentReportDetailQueryHandler(IContentReportRepository repo, IChannelEmojiRepository emojiRepository)
    {
        _repo = repo;
        _emojiRepository = emojiRepository;
    }

    public async Task<ContentReportDetailDto>
        HandleAsync(
            GetContentReportDetailQuery query,
            CancellationToken cancellationToken)
    {
        var detail = await _repo.GetContentReportDetailAsync(
                query.ContentId,
                query.IsVideo,
                cancellationToken) ?? throw new NotFoundException("Reported content doesn't exist.");

        if (query.IsVideo) return detail;

        var codes = EmojiParser.ExtractCodes(detail.ContentPreview);

        if (codes.Count == 0) return detail;

        var emojis = await _emojiRepository.GetByCodesAsync(codes, cancellationToken);

        var emojisDto = emojis.Select(x => new CommentEmojiDto(x.Code, x.ImageUrl)).ToList();

        return detail with
        {
            Emojis = emojisDto
        };


    }
}