using Microsoft.AspNetCore.Mvc;
using VidiVideo.Application.Common;
using VidiVideo.Application.Videos.Likes;

namespace VidiVideo.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class LikeController : ControllerBase
{
    private readonly ICommandHandler<LikeVideoCommand, LikeDto> _likeHandler;
    private readonly ICommandHandler<UnlikeVideoCommand, bool> _unlikeHandler;

    public LikeController(ICommandHandler<LikeVideoCommand, LikeDto> likeHandler, ICommandHandler<UnlikeVideoCommand, bool> unlikeHandler)
    {
        _likeHandler = likeHandler;
        _unlikeHandler = unlikeHandler;
    }

    [HttpPost("like")]
    public async Task<IActionResult> Like([FromBody] LikeDto request, CancellationToken cancellationToken)
    {
        var command = new LikeVideoCommand(request.UserId, request.VideoId);

        var response = await _likeHandler.HandleAsync(command, cancellationToken);

        return Ok(response);
    }
    [HttpDelete("unlike")]
    public async Task<IActionResult> Unlike([FromBody] LikeDto request, CancellationToken cancellation)
    {
        var command = new UnlikeVideoCommand(request.UserId, request.VideoId);

        var response = await _unlikeHandler.HandleAsync(command, cancellation);

        return Ok(response);
    }
}
