using VidiVideo.Application.Common;

namespace VidiVideo.Application.Videos.Likes;
public sealed record LikeVideoCommand(Guid userId, Guid videoId) : ICommand<LikeDto>;
