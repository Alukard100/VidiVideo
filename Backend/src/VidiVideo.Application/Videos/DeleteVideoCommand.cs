using VidiVideo.Application.Common;

namespace VidiVideo.Application.Videos;

public sealed record DeleteVideoCommand(Guid Id) : ICommand<bool>;
