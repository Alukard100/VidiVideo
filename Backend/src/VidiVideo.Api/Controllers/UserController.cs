using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VidiVideo.Application.Common;
using VidiVideo.Application.Users;
using VidiVideo.Application.Users.Administrative;
using VidiVideo.Domain.Constants;

namespace VidiVideo.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public sealed class UserController : ControllerBase
    {
        private readonly IQueryHandler<GetMyProfileQuery, CurrentUserProfileDto> _myProfileHandler;
        private readonly IQueryHandler<GetUserProfileQuery, UserProfileDto> _profileHandler;
        private readonly ICommandHandler<UpdateMyProfileCommand, Guid> _updateHandler;
        private readonly ICommandHandler<UploadAvatarCommand, string> _avatarHandler;
        private readonly IQueryHandler<GetUsersQuery, PagedResult<UserSummaryDto>> _usersHandler;
        private readonly ICommandHandler<UpdateUserStatusCommand, bool> _statusHandler;
        private readonly ICommandHandler<CreateStaffCommand, Guid> _addStaffHandler;
        private readonly ICommandHandler<UpdateStaffRoleCommand, bool> _updateStaffRoleHandler;
        private readonly ICommandHandler<DeleteStaffCommand, bool> _deleteStaffHandler;
        private readonly IQueryHandler<GetStaffCommand, List<StaffSummaryDto>> _staffGetHandler;

        public UserController(
            IQueryHandler<GetMyProfileQuery, CurrentUserProfileDto> myProfileHandler,
            IQueryHandler<GetUserProfileQuery, UserProfileDto> profileHandler,
            ICommandHandler<UpdateMyProfileCommand, Guid> updateHandler,
            ICommandHandler<UploadAvatarCommand, string> avatarHandler,
            IQueryHandler<GetUsersQuery, PagedResult<UserSummaryDto>> usersHandler,
            ICommandHandler<UpdateUserStatusCommand, bool> statusHandler,
            ICommandHandler<CreateStaffCommand, Guid> addStaffHandler,
            ICommandHandler<UpdateStaffRoleCommand, bool> updateStaffRoleHandler,
            ICommandHandler<DeleteStaffCommand, bool> deleteStaffHandler,
            IQueryHandler<GetStaffCommand, List<StaffSummaryDto>> staffGetHandler)
        {
            _myProfileHandler = myProfileHandler;
            _profileHandler = profileHandler;
            _updateHandler = updateHandler;
            _avatarHandler = avatarHandler;
            _usersHandler = usersHandler;
            _statusHandler = statusHandler;
            _addStaffHandler = addStaffHandler;
            _updateStaffRoleHandler = updateStaffRoleHandler;
            _deleteStaffHandler = deleteStaffHandler;
            _staffGetHandler = staffGetHandler;
        }

        [Authorize]
        [HttpGet("me")]
        public async Task<IActionResult> Me(
            CancellationToken cancellationToken)
        {
            var query = new GetMyProfileQuery();
            var result = await _myProfileHandler.HandleAsync(query, cancellationToken);

            return Ok(result);
        }

        [HttpGet("{userId:guid}/profile")]
        public async Task<IActionResult> Profile(
            Guid userId,
            CancellationToken cancellationToken)
        {
            var result = await _profileHandler.HandleAsync(
                new GetUserProfileQuery(userId),
                cancellationToken);

            return Ok(result);
        }

        [Authorize]
        [HttpPatch("me")]
        public async Task<IActionResult> Update(
            [FromBody] UpdateMyProfileCommand command,
            CancellationToken cancellationToken)
        {
            var result = await _updateHandler.HandleAsync(
                command,
                cancellationToken);

            return Ok(result);
        }

        [Authorize]
        [HttpPost("avatar")]
        public async Task<IActionResult> UploadAvatar(
            IFormFile formFile,
            CancellationToken cancellationToken)
        {
            var command = new UploadAvatarCommand(
                formFile.OpenReadStream(),
                formFile.FileName);

            var avatarUrl = await _avatarHandler.HandleAsync(
                command,
                cancellationToken);

            return Ok(new { avatarUrl });
        }

        [Authorize(Roles = $"{AppRoles.Admin},{AppRoles.Moderator},{AppRoles.SuperAdmin}")]
        [HttpGet("admin")]
        public async Task<IActionResult> GetUsers(
        [FromQuery] GetUsersQuery query,
        CancellationToken cancellationToken)
        {
            var result =
                await _usersHandler.HandleAsync(
                    query,
                    cancellationToken);

            return Ok(result);
        }

        [Authorize(Roles = $"{AppRoles.Admin},{AppRoles.Moderator},{AppRoles.SuperAdmin}")]
        [HttpPatch("{userId:guid}/status")]
        public async Task<IActionResult> UpdateStatus(
        Guid userId,
        [FromBody] UpdateUserStatusRequest request,
        CancellationToken cancellationToken)
        {
            var command =
                new UpdateUserStatusCommand(
                    userId,
                    request.Status);

            var result =
                await _statusHandler.HandleAsync(
                    command,
                    cancellationToken);

            return Ok(result);
        }

        [Authorize(Roles = $"{AppRoles.Admin},{AppRoles.SuperAdmin}")]
        [HttpPost("staff")]
        public async Task<IActionResult> Register([FromBody] AddStaffRequest request, CancellationToken cancellationToken)
        {
            var command = new CreateStaffCommand(request.UserName, request.Email, request.Password, request.DisplayName, request.Role);

            var userId = await _addStaffHandler.HandleAsync(command, cancellationToken);

            return Ok(userId);
        }

        [Authorize(Roles = $"{AppRoles.Admin},{AppRoles.SuperAdmin}")]
        [HttpDelete("staff/{targetId:guid}")]
        public async Task<IActionResult> DeleteStaff(Guid targetId, CancellationToken cancellationToken)
        {
            var command = new DeleteStaffCommand(targetId);

            var result = await _deleteStaffHandler.HandleAsync(command, cancellationToken);

            return Ok(result);
        }

        [Authorize(Roles = $"{AppRoles.SuperAdmin}")]
        [HttpPatch("staff/update")]
        public async Task<IActionResult> UpdateStaff([FromBody] UpdateStaffRoleRequest request, CancellationToken cancellationToken)
        {
            var command = new UpdateStaffRoleCommand(request.TargetId, request.Role);
            var result = await _updateStaffRoleHandler.HandleAsync(command, cancellationToken);

            return Ok(result);
        }

        [Authorize(Roles = $"{AppRoles.SuperAdmin},{AppRoles.Admin}")]
        [HttpGet("staff")]
        public async Task<IActionResult> GetStaff(CancellationToken cancellationToken)
        {
            var result = await _staffGetHandler.HandleAsync(new GetStaffCommand(), cancellationToken);
            return Ok(result);
        }
    }
}