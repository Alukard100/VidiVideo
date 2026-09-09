using VidiVideo.Application.Common;

namespace VidiVideo.Application.Followers;

public sealed record FollowersQuery(Guid TargetUserId) : PagedRequest, IQuery<PagedResult<UserFollowDto>>;