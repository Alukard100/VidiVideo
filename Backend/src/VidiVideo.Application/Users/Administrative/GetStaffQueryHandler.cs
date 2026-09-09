using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;
using VidiVideo.Domain.Constants;

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

            var search = string.IsNullOrWhiteSpace(query.Search) ? null : query.Search.Trim();
            var role = NormalizeStaffRole(query.Role);

            var staff = await _userRepository.GetStaffAsync(search, role, query.Page, query.PageSize, cancellationToken);

            var count = await _userRepository.CountStaffAsync(search, role, cancellationToken);

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

        private static string? NormalizeStaffRole(string? role)
        {
            if (string.IsNullOrWhiteSpace(role))
                return null;

            return role.Trim().ToLowerInvariant() switch
            {
                "super admin" => AppRoles.SuperAdmin,
                "admin" => AppRoles.Admin,
                "moderator" => AppRoles.Moderator,
                _ => throw new ValidationException("Invalid staff role filter")
            };
        }
    }
}
