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
    private readonly ICommandHandler<ChangePasswordCommand, bool> _changePasswordHandler;
    private readonly ICommandHandler<ForgetPasswordCommand, bool> _forgetPasswordHandler;
    private readonly ICommandHandler<ResetPasswordCommand, bool> _resetPasswordHandler;
    private readonly ICommandHandler<LogoutCommand, bool> _logoutHandler;

    public AuthController(ICommandHandler<RegisterUserCommand, Guid> registerHandler, ICommandHandler<LoginUserCommand, LoginUserResponse> loginHandler, ICommandHandler<ChangePasswordCommand, bool> changePasswordHandler, ICommandHandler<ForgetPasswordCommand, bool> forgetPasswordHandler, ICommandHandler<ResetPasswordCommand, bool> resetPasswordHandler, ICommandHandler<LogoutCommand, bool> logoutHandler)
    {
        _registerHandler = registerHandler;
        _loginHandler = loginHandler;
        _changePasswordHandler = changePasswordHandler;
        _forgetPasswordHandler = forgetPasswordHandler;
        _resetPasswordHandler = resetPasswordHandler;
        _logoutHandler = logoutHandler;
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
    [HttpPost("change-password")]
    public async Task<IActionResult> ChangePassword(
        [FromBody] ChangePasswordRequest request,
        CancellationToken cancellationToken)
    {
        var command = new ChangePasswordCommand(
            request.OldPassword,
            request.NewPassword);

        var response = await _changePasswordHandler.HandleAsync(command, cancellationToken);

        return Ok(response);
    }

    [HttpPost("forgot-password")]
    public async Task<IActionResult> ForgotPassword([FromBody] ForgetPasswordRequest request, CancellationToken cancellationToken)
    {
        await _forgetPasswordHandler.HandleAsync(
            new ForgetPasswordCommand(
                request.Email),
            cancellationToken);

        return Ok(new
        {
            message = "If an account exists for this email, a reset code has been sent."
        });
    }

    [HttpPost("reset-password")]
    public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordRequest request, CancellationToken cancellationToken)
    {
        await _resetPasswordHandler.HandleAsync(
            new ResetPasswordCommand(
                request.Email,
                request.Code,
                request.NewPassword),
            cancellationToken);

        return Ok(new
        {
            message = "Password has been reset successfully."
        });
    }

    [Authorize]
    [HttpPost("logout")]
    public async Task<IActionResult> Logout(CancellationToken cancellationToken)
    {
        await _logoutHandler.HandleAsync(
            new LogoutCommand(),
            cancellationToken);

        return Ok();
    }

    [Authorize]
    [HttpGet("me")]
    public IActionResult Me()
    {
        return Ok("Authenticated");
    }
}
