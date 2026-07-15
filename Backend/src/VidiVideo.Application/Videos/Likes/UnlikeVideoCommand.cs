using VidiVideo.Application.Common;

namespace VidiVideo.Application.Videos.Likes;
public sealed record UnlikeVideoCommand(Guid VideoId) : ICommand<bool>;

