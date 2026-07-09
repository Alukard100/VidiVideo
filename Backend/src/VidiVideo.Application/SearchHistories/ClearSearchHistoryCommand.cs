using VidiVideo.Application.Common;

namespace VidiVideo.Application.SearchHistories;

public sealed record ClearSearchHistoryCommand(Guid Id) : ICommand<bool>;
