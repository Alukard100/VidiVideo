using VidiVideo.Application.Common;

namespace VidiVideo.Application.Users.Administrative;

public sealed record GetStaffCommand : IQuery<List<StaffSummaryDto>>;
