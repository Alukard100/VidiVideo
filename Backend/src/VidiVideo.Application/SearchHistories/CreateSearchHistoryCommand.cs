using VidiVideo.Application.Common;

namespace VidiVideo.Application.SearchHistories;

public sealed record CreateSearchHistoryCommand(Guid UserId, string Query) : ICommand<Guid>;
