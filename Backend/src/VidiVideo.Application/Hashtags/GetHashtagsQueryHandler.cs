using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;

namespace VidiVideo.Application.Hashtags;

public sealed class GetHashtagsQueryHandler : IQueryHandler<GetHashtagsQuery, List<HashtagDto>>
{

    private readonly IHashtagRepository _repo;

    public GetHashtagsQueryHandler(IHashtagRepository repo)
    {
        _repo = repo;
    }

    public async Task<List<HashtagDto>> HandleAsync(GetHashtagsQuery query, CancellationToken cancellationToken)
    {
        var hashtags = await _repo.GetAllHashtagsAsync();

        return hashtags
            .Select(h => new HashtagDto(
                h.Id, h.Name))
            .ToList();
    }
}
