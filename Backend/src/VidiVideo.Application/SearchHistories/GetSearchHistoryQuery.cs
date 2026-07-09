using VidiVideo.Application.Common;

namespace VidiVideo.Application.SearchHistories;

public sealed record GetSearchHistoryQuery(Guid UserId) : PagedRequest, IQuery<PagedResult<SearchHistoryDto>>;
