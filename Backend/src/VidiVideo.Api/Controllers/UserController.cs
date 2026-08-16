using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VidiVideo.Application.Common;
using VidiVideo.Application.Users;

[ApiController]
[Route("api/[controller]")]
public sealed class UserController : ControllerBase
{
    private readonly IQueryHandler<GetMyProfileQuery, CurrentUserProfileDto> _myProfileHandler;
    private readonly IQueryHandler<GetUserProfileQuery, UserProfileDto> _profileHandler;
    private readonly ICommandHandler<UpdateMyProfileCommand, Guid> _updateHandler;
    private readonly ICommandHandler<UploadAvatarCommand, string> _avatarHandler;

    public UserController(
        IQueryHandler<GetMyProfileQuery, CurrentUserProfileDto> myProfileHandler,
        IQueryHandler<GetUserProfileQuery, UserProfileDto> profileHandler,
        ICommandHandler<UpdateMyProfileCommand, Guid> updateHandler,
        ICommandHandler<UploadAvatarCommand, string> avatarHandler)
    {
        _myProfileHandler = myProfileHandler;
        _profileHandler = profileHandler;
        _updateHandler = updateHandler;
        _avatarHandler = avatarHandler;
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
}