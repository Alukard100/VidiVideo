using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;

namespace VidiVideo.Application.ChannelEmojis.Queries;

public sealed class GetAvailableChannelEmojisQueryHandler : IQueryHandler<GetAvailableChannelEmojisQuery, PagedResult<ChannelEmojiDto>>
{
    private readonly ICurrentUser _currentUser;
    private readonly IChannelEmojiRepository _emojiRepository;
    public GetAvailableChannelEmojisQueryHandler(ICurrentUser currentUser, IChannelEmojiRepository emojiRepository)
    {
        _currentUser = currentUser;
        _emojiRepository = emojiRepository;
    }
    public async Task<PagedResult<ChannelEmojiDto>> HandleAsync(GetAvailableChannelEmojisQuery query, CancellationToken cancellationToken)
    {
        var userId = _currentUser.UserId ?? throw new UnauthorizedException("Must be logged in");
        var emojis = await _emojiRepository.GetAvailableForUserAsync(userId, query.Page, query.PageSize, cancellationToken);

        var count = await _emojiRepository.CountAvailableForUserAsync(userId, cancellationToken);

        var items = emojis.Select(x => new ChannelEmojiDto(x.Id, x.CreatorId, x.Creator.DisplayName, x.Code, x.ImageUrl)).ToList();

        return new PagedResult<ChannelEmojiDto>(items, query.Page, query.PageSize, count);
    }
}
