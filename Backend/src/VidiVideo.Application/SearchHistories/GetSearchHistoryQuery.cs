using VidiVideo.Application.Common;

namespace VidiVideo.Application.SearchHistories;

public sealed record GetSearchHistoryQuery() : PagedRequest, IQuery<PagedResult<SearchHistoryDto>>;
