using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VidiVideo.Application.Common;
using VidiVideo.Application.ContentReports;
using VidiVideo.Domain.Constants;

namespace VidiVideo.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ContentReportController : ControllerBase
    {
        private readonly ICommandHandler<CreateContentReportCommand, Guid> _createHandler;
        private readonly ICommandHandler<ReviewContentReportCommand, Guid> _reviewHandler;
        private readonly IQueryHandler<GetContentReportsQuery, PagedResult<ContentReportDto>> _queryHandler;

        public ContentReportController(ICommandHandler<CreateContentReportCommand, Guid> createHandler,
            ICommandHandler<ReviewContentReportCommand, Guid> reviewHandler,
            IQueryHandler<GetContentReportsQuery, PagedResult<ContentReportDto>> queryHandler)
        {
            _createHandler = createHandler;
            _reviewHandler = reviewHandler;
            _queryHandler = queryHandler;
        }

        [Authorize]
        [HttpPost("report")]
        public async Task<IActionResult> Create([FromBody] CreateContentReportCommand command, CancellationToken cancellationToken)
        {
            var responseId = await _createHandler.HandleAsync(command, cancellationToken);

            return Ok(responseId);
        }

        [Authorize(Roles = $"{AppRoles.Admin},{AppRoles.Moderator}")]
        [HttpPatch("review-report")]
        public async Task<IActionResult> Review([FromBody] ReviewContentReportCommand command, CancellationToken cancellationToken)
        {
            var responseId = await _reviewHandler.HandleAsync(command, cancellationToken);

            return Ok(responseId);
        }

        [Authorize]
        [HttpGet("getall")]
        public async Task<IActionResult> GetAll([FromQuery] GetContentReportsQuery query, CancellationToken cancellationToken)
        {
            var result = await _queryHandler.HandleAsync(query, cancellationToken);

            return Ok(result);
        }
    }
}
