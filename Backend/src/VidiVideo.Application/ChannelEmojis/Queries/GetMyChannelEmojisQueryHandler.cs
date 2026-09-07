using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;

namespace VidiVideo.Application.ChannelEmojis.Queries;

public sealed class GetMyChannelEmojisQueryHandler : IQueryHandler<GetMyChannelEmojisQuery, PagedResult<ChannelEmojiDto>>
{
    private readonly ICurrentUser _currentUser;
    private readonly IChannelEmojiRepository _channelEmojiRepository;

    public GetMyChannelEmojisQueryHandler(ICurrentUser currentUser, IChannelEmojiRepository channelEmojiRepository)
    {
        _currentUser = currentUser;
        _channelEmojiRepository = channelEmojiRepository;
    }

    public async Task<PagedResult<ChannelEmojiDto>> HandleAsync(GetMyChannelEmojisQuery query, CancellationToken cancellationToken)
    {
        var userId = _currentUser.UserId ?? throw new UnauthorizedException("Must be logged in");

        var emojis = await _channelEmojiRepository.GetByCreatorAsync(userId, query.Page, query.PageSize, cancellationToken);
        var count = await _channelEmojiRepository.CountByCreatorAsync(userId, cancellationToken);

        var items = emojis
            .Select(x => new ChannelEmojiDto(x.Id, x.CreatorId, x.Creator.DisplayName, x.Code, x.ImageUrl))
            .ToList();

        return new PagedResult<ChannelEmojiDto>(items, query.Page, query.PageSize, count);

    }
}
