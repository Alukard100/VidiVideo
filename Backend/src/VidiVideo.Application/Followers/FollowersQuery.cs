using VidiVideo.Application.Common;

namespace VidiVideo.Application.Followers;

public sealed record FollowersQuery(Guid CurrentUserId, Guid TargetUserId) : PagedRequest, IQuery<PagedResult<UserFollowDto>>;