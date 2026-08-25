using VidiVideo.Application.Common;
using VidiVideo.Domain.Enums;

namespace VidiVideo.Application.Users.Administrative;

public sealed record GetUsersQuery : PagedRequest, IQuery<PagedResult<UserSummaryDto>>
{
    public string? Search { get; init; }
    public UserStatus? Status { get; init; }
    public UserSortBy SortBy { get; init; } = UserSortBy.RegistrationDate;
    public SortDirection SortWay { get; init; } = SortDirection.Descending;
}
