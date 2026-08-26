using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;

namespace VidiVideo.Application.Hashtags;

public sealed class GetHashtagsQueryHandler : IQueryHandler<GetHashtagsQuery, PagedResult<HashtagDto>>
{

    private readonly IHashtagRepository _repo;

    public GetHashtagsQueryHandler(IHashtagRepository repo)
    {
        _repo = repo;
    }

    public async Task<PagedResult<HashtagDto>> HandleAsync(GetHashtagsQuery query, CancellationToken cancellationToken)
    {
        var hashtags = await _repo.GetAllHashtagsAsync(query.Page, query.PageSize, cancellationToken);

        var count = await _repo.CountAsync(cancellationToken);

        var items = hashtags.Select(h => new HashtagDto(h.Id, h.Name)).ToList();

        return new PagedResult<HashtagDto>(items, query.Page, query.PageSize, count);

    }
}
