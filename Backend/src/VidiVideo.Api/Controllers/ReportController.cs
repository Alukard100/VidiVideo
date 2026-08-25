using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VidiVideo.Application.Common;
using VidiVideo.Application.Dashboard;
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
        private readonly IQueryHandler<GetDashboardOverviewQuery, DashboardOverviewDto> _dashboardOverviewHandler;

        public ReportController(IQueryHandler<GenerateRevenueReportQuery, byte[]> revenueHandler, IQueryHandler<GenerateVideosReportQuery, byte[]> videoAnalyticsHandler, IQueryHandler<GetDashboardOverviewQuery, DashboardOverviewDto> dashboardOverviewHandler)
        {
            _revenueHandler = revenueHandler;
            _videoAnalyticsHandler = videoAnalyticsHandler;
            _dashboardOverviewHandler = dashboardOverviewHandler;
        }

        [Authorize(Roles = $"{AppRoles.SuperAdmin},{AppRoles.Admin},{AppRoles.Moderator}")]
        [HttpGet("dashboard")]
        public async Task<IActionResult> Dashboard(CancellationToken cancellationToken)
        {
            return Ok(await _dashboardOverviewHandler.HandleAsync(new GetDashboardOverviewQuery(), cancellationToken));
        }

        [Authorize(Roles = $"{AppRoles.Admin},{AppRoles.SuperAdmin},{AppRoles.Moderator}")]
        [HttpGet("revenue-report")]
        public async Task<IActionResult> RevenueReport([FromQuery] GenerateRevenueReportQuery query, CancellationToken cancellationToken)
        {
            var result = await _revenueHandler.HandleAsync(query, cancellationToken);

            return File(result, "application/pdf", $"revenue-report-{DateTime.UtcNow:yyyy-MM-dd}.pdf");
        }

        [Authorize(Roles = $"{AppRoles.Admin},{AppRoles.SuperAdmin},{AppRoles.Moderator}")]
        [HttpGet("video-analytics-report")]
        public async Task<IActionResult> AnalyticsReport([FromQuery] GenerateVideosReportQuery query, CancellationToken cancellationToken)
        {
            var result = await _videoAnalyticsHandler.HandleAsync(query, cancellationToken);

            return File(result, "application/pdf", $"video-analytics-{DateTime.UtcNow:yyyy-MM-dd}.pdf");

        }




    }
}
