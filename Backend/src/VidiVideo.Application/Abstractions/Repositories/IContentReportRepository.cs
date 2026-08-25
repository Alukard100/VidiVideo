using VidiVideo.Application.ContentReports;
using VidiVideo.Domain.Entities;
using VidiVideo.Domain.Enums;

namespace VidiVideo.Application.Abstractions.Repositories;

public interface IContentReportRepository
{
    Task CreateAsync(
        ContentReport report,
        CancellationToken cancellationToken = default);

    Task<ContentReport?> GetByIdAsync(
        Guid id,
        CancellationToken cancellationToken = default);

    Task<List<ContentReportSummaryDto>> GetGroupedAsync(
        ReportStatus? status,
        int page,
        int pageSize,
        CancellationToken cancellationToken = default);

    Task<int> CountGroupedAsync(
        ReportStatus? status,
        CancellationToken cancellationToken = default);

    Task<ContentReportDetailDto?> GetContentReportDetailAsync(
        Guid contentId,
        bool isVideo,
        CancellationToken cancellationToken = default);

    Task<List<ContentReport>> GetByContentAsync(
        Guid contentId,
        bool isVideo,
        CancellationToken cancellationToken = default);

    Task<ContentReportStatsDto> GetStatsAsync(CancellationToken cancellationToken = default);

    Task<List<ContentReport>> GetByStatusAsync(ReportStatus status, int _page = 1, int _pageSize = 10, CancellationToken cancellationToken = default);
    Task<int> CountByStatusAsync(ReportStatus status, CancellationToken cancellationToken = default);
    Task<int> CountAsync(CancellationToken cancellationToken = default);
}