using VidiVideo.Application.Common;

namespace VidiVideo.Application.SearchHistories;

public sealed record CreateSearchHistoryCommand(string Query) : ICommand<Guid>;
