using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;

namespace VidiVideo.Application.Users.Administrative
{
    public sealed class GetStaffQueryHandler : IQueryHandler<GetStaffQuery, PagedResult<StaffSummaryDto>>
    {
        private readonly IUserRepository _userRepository;
        public GetStaffQueryHandler(IUserRepository userRepository)
        {
            _userRepository = userRepository;
        }

        public async Task<PagedResult<StaffSummaryDto>> HandleAsync(GetStaffQuery query, CancellationToken cancellationToken)
        {

            var staff = await _userRepository.GetStaffAsync(query.Page, query.PageSize, cancellationToken);

            var count = await _userRepository.CountStaffAsync(cancellationToken);

            var response = staff.Select(s => new StaffSummaryDto(
                s.Id,
                s.UserName,
                s.Email,
                s.DisplayName,
                s.AvatarUrl,
                s.Role,
                s.CreatedAtUtc
                )).ToList();

            return new PagedResult<StaffSummaryDto>(response, query.Page, query.PageSize, count);

        }
    }
}
