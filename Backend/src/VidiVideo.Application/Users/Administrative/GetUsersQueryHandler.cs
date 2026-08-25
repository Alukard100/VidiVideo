using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;

namespace VidiVideo.Application.Users.Administrative;

public sealed class GetUsersQueryHandler : IQueryHandler<GetUsersQuery, PagedResult<UserSummaryDto>>
{
    private readonly IUserRepository _repo;

    public GetUsersQueryHandler(IUserRepository repo)
    {
        _repo = repo;
    }
    public async Task<PagedResult<UserSummaryDto>> HandleAsync(GetUsersQuery query, CancellationToken cancellationToken)
    {
        var count = await _repo.CountFilteredUsersAsync(query.Search, query.Status, cancellationToken);

        var users = await _repo.GetFilteredUsersAsync(query.Search, query.Status, query.SortBy, query.SortWay, query.Page, query.PageSize, cancellationToken);

        var items = users.Select(u => new UserSummaryDto(
            u.Id,
            u.UserName,
            u.DisplayName,
            u.Email,
            u.AvatarUrl,
            u.CreatedAtUtc,
            u.Videos.Count,
            u.Followers.Count,
            u.Status.ToString()
        )).ToList();

        return new PagedResult<UserSummaryDto>(items, query.Page, query.PageSize, count);
    }
}
