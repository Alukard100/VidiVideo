using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;

namespace VidiVideo.Application.Users.Administrative
{
    public sealed class GetStaffCommandHandler : IQueryHandler<GetStaffCommand, List<StaffSummaryDto>>
    {
        private readonly IUserRepository _userRepository;
        public GetStaffCommandHandler(IUserRepository userRepository)
        {
            _userRepository = userRepository;
        }

        public async Task<List<StaffSummaryDto>> HandleAsync(GetStaffCommand command, CancellationToken cancellationToken)
        {

            var staff = await _userRepository.GetStaffAsync(cancellationToken);

            var response = staff.Select(s => new StaffSummaryDto(
                s.Id,
                s.UserName,
                s.Email,
                s.DisplayName,
                s.AvatarUrl,
                s.Role,
                s.CreatedAtUtc
                )).ToList();

            return response;

        }
    }
}
