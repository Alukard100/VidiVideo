using VidiVideo.Application.Common;

namespace VidiVideo.Application.SearchHistories;

public sealed record DeleteSearchHistoryCommand(Guid Id) : ICommand<bool>;
