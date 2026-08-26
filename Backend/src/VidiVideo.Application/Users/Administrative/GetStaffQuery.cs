using VidiVideo.Application.Common;

namespace VidiVideo.Application.Users.Administrative;

public sealed record GetStaffQuery : PagedRequest, IQuery<PagedResult<StaffSummaryDto>>;
