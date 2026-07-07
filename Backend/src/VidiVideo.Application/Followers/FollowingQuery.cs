using VidiVideo.Application.Common;

namespace VidiVideo.Application.Followers;

public sealed record FollowingQuery(Guid CurrentUserId, Guid TargetUserId) : PagedRequest, IQuery<PagedResult<UserFollowDto>>;
