using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VidiVideo.Application.Common;
using VidiVideo.Application.Reports.RevenueReport;
using VidiVideo.Application.Reports.VideosReport;
using VidiVideo.Domain.Constants;

namespace VidiVideo.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ReportController : ControllerBase
    {
        private readonly IQueryHandler<GenerateRevenueReportQuery, byte[]> _revenueHandler;
        private readonly IQueryHandler<GenerateVideosReportQuery, byte[]> _videoAnalyticsHandler;

        public ReportController(IQueryHandler<GenerateRevenueReportQuery, byte[]> revenueHandler, IQueryHandler<GenerateVideosReportQuery, byte[]> videoAnalyticsHandler)
        {
            _revenueHandler = revenueHandler;
            _videoAnalyticsHandler = videoAnalyticsHandler;
        }

        [Authorize(Roles = AppRoles.Admin)]
        [HttpGet("revenue-report")]
        public async Task<IActionResult> RevenueReport(GenerateRevenueReportQuery query, CancellationToken cancellationToken)
        {
            var result = await _revenueHandler.HandleAsync(query, cancellationToken);

            return Ok(result);
        }

        [Authorize(Roles = AppRoles.Admin)]
        [HttpGet("video-analytics-report")]
        public async Task<IActionResult> AnalyticsReport(GenerateVideosReportQuery query, CancellationToken cancellationToken)
        {
            var result = await _videoAnalyticsHandler.HandleAsync(query, cancellationToken);

            return Ok(result);
        }
    }
}
