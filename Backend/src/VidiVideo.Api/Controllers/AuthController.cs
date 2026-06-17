using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VidiVideo.Application.Common;
using VidiVideo.Application.Users;

namespace VidiVideo.Api.Controllers;

[ApiController]
[Route("api/auth")]
public sealed class AuthController : ControllerBase
{
    private readonly ICommandHandler<RegisterUserCommand, Guid> _registerHandler;
    private readonly ICommandHandler<LoginUserCommand, LoginUserResponse> _loginHandler;

    public AuthController(ICommandHandler<RegisterUserCommand, Guid> registerHandler, ICommandHandler<LoginUserCommand, LoginUserResponse> loginHandler)
    {
        _registerHandler = registerHandler;
        _loginHandler = loginHandler;
    }

    [HttpPost("register")]
    public async Task<IActionResult> Register([FromBody] RegisterUserRequest request, CancellationToken cancellationToken)
    {
        var command = new RegisterUserCommand(request.UserName, request.Email, request.Password, request.DisplayName);

        var userId = await _registerHandler.HandleAsync(command, cancellationToken);

        return Ok(userId);
    }

    [HttpPost("login")]
    public async Task<ActionResult<LoginUserResponse>> Login([FromBody] LoginUserRequest request, CancellationToken cancellationToken)
    {
        var command = new LoginUserCommand(request.UserName, request.Password);

        var response = await _loginHandler.HandleAsync(command, cancellationToken);

        return Ok(response);
    }

    [Authorize]
    [HttpGet("me")]
    public IActionResult Me()
    {
        return Ok("Authenticated");
    }
}
