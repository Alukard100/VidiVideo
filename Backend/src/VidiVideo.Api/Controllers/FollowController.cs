using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VidiVideo.Application.Common;
using VidiVideo.Application.Followers;

namespace VidiVideo.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class FollowController : ControllerBase
    {
        private readonly ICommandHandler<FollowCommand, bool> _followHandler;
        private readonly ICommandHandler<UnfollowCommand, bool> _unfollowHandler;
        private readonly IQueryHandler<FollowingQuery, PagedResult<UserFollowDto>> _followingHandler;
        private readonly IQueryHandler<FollowersQuery, PagedResult<UserFollowDto>> _followersHandler;

        public FollowController(ICommandHandler<FollowCommand, bool> followHandler, ICommandHandler<UnfollowCommand, bool> unfollowHandler, IQueryHandler<FollowingQuery, PagedResult<UserFollowDto>> followingHandler, IQueryHandler<FollowersQuery, PagedResult<UserFollowDto>> followersHandler)
        {
            _followHandler = followHandler;
            _unfollowHandler = unfollowHandler;
            _followingHandler = followingHandler;
            _followersHandler = followersHandler;
        }

        [Authorize]
        [HttpPost("follow")]
        public async Task<IActionResult> Follow([FromBody] FollowRequest request, CancellationToken cancellationToken)
        {
            var command = new FollowCommand(request.TargeTuserId);

            var response = await _followHandler.HandleAsync(command, cancellationToken);

            return Ok(response);
        }

        [Authorize]
        [HttpDelete("unfollow")]
        public async Task<IActionResult> Unfollow([FromBody] FollowRequest request, CancellationToken cancellationToken)
        {
            var command = new UnfollowCommand(request.TargeTuserId);

            var response = await _unfollowHandler.HandleAsync(command, cancellationToken);

            return Ok(response);
        }

        [Authorize]
        [HttpGet("followers")]
        public async Task<IActionResult> Followers([FromQuery] FollowersQuery query, CancellationToken cancellationToken)
        {
            var results = await _followersHandler.HandleAsync(query, cancellationToken);

            return Ok(results);
        }

        [Authorize]
        [HttpGet("following")]
        public async Task<IActionResult> Following([FromQuery] FollowingQuery query, CancellationToken cancellationToken)
        {
            var results = await _followingHandler.HandleAsync(query, cancellationToken);

            return Ok(results);
        }

    }
}
