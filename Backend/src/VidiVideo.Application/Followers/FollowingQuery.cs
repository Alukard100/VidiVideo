using VidiVideo.Application.Common;

namespace VidiVideo.Application.Followers;

public sealed record FollowingQuery(Guid TargetUserId) : PagedRequest, IQuery<PagedResult<UserFollowDto>>;
