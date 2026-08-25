using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VidiVideo.Application.Common;
using VidiVideo.Application.ContentReports;
using VidiVideo.Application.Videos.VideoFile;
using VidiVideo.Domain.Constants;

namespace VidiVideo.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ContentReportController : ControllerBase
    {
        private readonly ICommandHandler<CreateContentReportCommand, Guid> _createHandler;
        private readonly ICommandHandler<ReviewContentReportCommand, bool> _reviewHandler;
        private readonly IQueryHandler<GetContentReportsQuery, PagedResult<ContentReportSummaryDto>> _queryHandler;
        private readonly IQueryHandler<GetContentReportDetailQuery, ContentReportDetailDto> _detailHandler;
        private readonly IQueryHandler<GetContentReportStatsQuery, ContentReportStatsDto> _statsHandler;
        private readonly ICommandHandler<RemoveReportedContentCommand, bool> _removeContentHandler;
        private readonly IQueryHandler<GetModerationVideoStreamQuery, VideoStreamResult> _moderationVideoStreamHandler;
        private readonly IQueryHandler<GetReportsByStatusQuery, PagedResult<ContentReportDto>> _reportsByStatusHandler;


        public ContentReportController(ICommandHandler<CreateContentReportCommand, Guid> createHandler,
            ICommandHandler<ReviewContentReportCommand, bool> reviewHandler,
            IQueryHandler<GetContentReportsQuery, PagedResult<ContentReportSummaryDto>> queryHandler,
            IQueryHandler<GetContentReportDetailQuery, ContentReportDetailDto> detailHandler,
            IQueryHandler<GetContentReportStatsQuery, ContentReportStatsDto> statsHandler,
            ICommandHandler<RemoveReportedContentCommand, bool> removeContentHandler,
            IQueryHandler<GetModerationVideoStreamQuery, VideoStreamResult> moderationVideoStreamHandler,
            IQueryHandler<GetReportsByStatusQuery, PagedResult<ContentReportDto>> reportsByStatusHandler)
        {
            _createHandler = createHandler;
            _reviewHandler = reviewHandler;
            _queryHandler = queryHandler;
            _detailHandler = detailHandler;
            _statsHandler = statsHandler;
            _removeContentHandler = removeContentHandler;
            _moderationVideoStreamHandler = moderationVideoStreamHandler;
            _reportsByStatusHandler = reportsByStatusHandler;
        }

        [Authorize]
        [HttpPost("report")]
        public async Task<IActionResult> Create([FromBody] CreateContentReportCommand command, CancellationToken cancellationToken)
        {
            var responseId = await _createHandler.HandleAsync(command, cancellationToken);

            return Ok(responseId);
        }

        [Authorize(Roles = $"{AppRoles.SuperAdmin},{AppRoles.Admin},{AppRoles.Moderator}")]
        [HttpPatch("review-report")]
        public async Task<IActionResult> Review([FromBody] ReviewContentReportCommand command, CancellationToken cancellationToken)
        {
            var responseId = await _reviewHandler.HandleAsync(command, cancellationToken);

            return Ok(responseId);
        }

        [Authorize(Roles = $"{AppRoles.SuperAdmin},{AppRoles.Admin},{AppRoles.Moderator}")]
        [HttpGet("getall")]
        public async Task<IActionResult> GetAll([FromQuery] GetContentReportsQuery query, CancellationToken cancellationToken)
        {
            var result = await _queryHandler.HandleAsync(query, cancellationToken);

            return Ok(result);
        }

        [Authorize(Roles = $"{AppRoles.SuperAdmin},{AppRoles.Admin},{AppRoles.Moderator}")]
        [HttpGet("{contentType}/{contentId:guid}")]
        public async Task<IActionResult> Detail(string contentType, Guid contentId, CancellationToken cancellationToken)
        {
            var isVideo =
                contentType.Equals(
                    "video",
                    StringComparison.OrdinalIgnoreCase);

            if (!isVideo &&
                !contentType.Equals(
                    "comment",
                    StringComparison.OrdinalIgnoreCase))
            {
                return BadRequest(
                    "Invalid content type.");
            }

            var query =
                new GetContentReportDetailQuery(
                    contentId,
                    isVideo);

            return Ok(
                await _detailHandler.HandleAsync(
                    query,
                    cancellationToken));
        }

        [Authorize(Roles = $"{AppRoles.SuperAdmin},{AppRoles.Admin},{AppRoles.Moderator}")]
        [HttpGet("stats")]
        public async Task<IActionResult> Stats(CancellationToken cancellationToken)
        {
            var result = await _statsHandler.HandleAsync(
                new GetContentReportStatsQuery(),
                cancellationToken);

            return Ok(result);
        }

        [Authorize(Roles = $"{AppRoles.SuperAdmin},{AppRoles.Admin},{AppRoles.Moderator}")]
        [HttpPatch("remove-content")]
        public async Task<IActionResult> RemoveContent(
            [FromBody] RemoveReportedContentCommand command,
            CancellationToken cancellationToken)
        {
            return Ok(
                await _removeContentHandler.HandleAsync(
                    command,
                    cancellationToken));
        }

        [Authorize(Roles = $"{AppRoles.SuperAdmin},{AppRoles.Admin},{AppRoles.Moderator}")]
        [HttpGet("moderation/{videoId:guid}/stream")]
        public async Task<IActionResult> ModerationStream(Guid videoId, CancellationToken cancellationToken)
        {
            var result = await _moderationVideoStreamHandler.HandleAsync(
                new GetModerationVideoStreamQuery(videoId),
                cancellationToken);

            return File(
                result.Stream,
                result.ContentType,
                enableRangeProcessing: true);
        }

        [Authorize(Roles = $"{AppRoles.SuperAdmin},{AppRoles.Admin},{AppRoles.Moderator}")]
        [HttpGet("by-status")]
        public async Task<IActionResult> GetByStatus([FromQuery] GetReportsByStatusQuery query, CancellationToken cancellationToken)
        {
            return Ok(
                await _reportsByStatusHandler.HandleAsync(
                    query,
                    cancellationToken));
        }
    }
}
