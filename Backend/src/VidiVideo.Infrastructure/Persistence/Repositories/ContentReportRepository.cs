using Microsoft.EntityFrameworkCore;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.ContentReports;
using VidiVideo.Domain.Entities;
using VidiVideo.Domain.Enums;

namespace VidiVideo.Infrastructure.Persistence.Repositories;

public sealed class ContentReportRepository : IContentReportRepository
{
    private readonly VidiVideoDbContext _db;

    public ContentReportRepository(
        VidiVideoDbContext db)
    {
        _db = db;
    }

    public async Task CreateAsync(
        ContentReport report,
        CancellationToken cancellationToken = default)
    {
        await _db.ContentReports.AddAsync(
            report,
            cancellationToken);
    }

    public async Task<ContentReport?> GetByIdAsync(
        Guid id,
        CancellationToken cancellationToken = default)
    {
        return await _db.ContentReports
            .FirstOrDefaultAsync(
                x => x.Id == id,
                cancellationToken);
    }

    public async Task<List<ContentReportSummaryDto>>
        GetGroupedAsync(
            ReportStatus? status,
            int page,
            int pageSize,
            CancellationToken cancellationToken = default)
    {
        var query = _db.ContentReports
            .AsNoTracking()
            .Include(r => r.Video)
                .ThenInclude(v => v!.Creator)
            .Include(r => r.Comment)
                .ThenInclude(c => c!.Author)
            .AsQueryable();

        if (status.HasValue)
        {
            query = query.Where(
                r => r.Status == status.Value);
        }

        var reports = await query
            .ToListAsync(cancellationToken);

        var grouped = reports
            .GroupBy(r => new
            {
                ContentId =
                    r.VideoId ??
                    r.CommentId!.Value,

                IsVideo =
                    r.VideoId.HasValue
            })
            .Select(group =>
            {
                var first = group.First();

                var isVideo =
                    group.Key.IsVideo;

                var creatorId = isVideo
                    ? first.Video!.CreatorId
                    : first.Comment!.AuthorId;

                var creatorName = isVideo
                    ? first.Video!.Creator.DisplayName
                    : first.Comment!.Author.DisplayName;

                var preview = isVideo
                    ? first.Video!.Caption
                    : first.Comment!.Body;

                var resolvedStatus =
                    ResolveGroupStatus(group);

                return new ContentReportSummaryDto(
                    group.Key.ContentId,
                    isVideo
                        ? "Video"
                        : "Comment",
                    creatorId,
                    creatorName,
                    preview,
                    group.Count(),
                    resolvedStatus,
                    group.Max(
                        x => x.CreatedAtUtc));
            })
            .OrderByDescending(
                x => x.LastReportedAtUtc)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToList();

        return grouped;
    }

    public async Task<int> CountGroupedAsync(
        ReportStatus? status,
        CancellationToken cancellationToken = default)
    {
        var query = _db.ContentReports
            .AsNoTracking()
            .AsQueryable();

        if (status.HasValue)
        {
            query = query.Where(
                r => r.Status == status.Value);
        }

        var reports = await query
            .Select(r => new
            {
                ContentId =
                    r.VideoId ??
                    r.CommentId!.Value,

                IsVideo =
                    r.VideoId.HasValue
            })
            .Distinct()
            .CountAsync(cancellationToken);

        return reports;
    }

    public async Task<ContentReportDetailDto?>
        GetContentReportDetailAsync(
            Guid contentId,
            bool isVideo,
            CancellationToken cancellationToken = default)
    {
        var query = _db.ContentReports
            .AsNoTracking()
            .Include(r => r.Reporter)
            .Include(r => r.Video)
                .ThenInclude(v => v!.Creator)
            .Include(r => r.Comment)
                .ThenInclude(c => c!.Author)
            .AsQueryable();

        query = isVideo
            ? query.Where(
                r => r.VideoId == contentId)
            : query.Where(
                r => r.CommentId == contentId);

        var reports = await query
            .OrderByDescending(
                r => r.CreatedAtUtc)
            .ToListAsync(cancellationToken);

        if (reports.Count == 0)
        {
            return null;
        }

        var first = reports[0];

        var creatorId = isVideo
            ? first.Video!.CreatorId
            : first.Comment!.AuthorId;

        var creatorName = isVideo
            ? first.Video!.Creator.DisplayName
            : first.Comment!.Author.DisplayName;

        var preview = isVideo
            ? first.Video!.Caption
            : first.Comment!.Body;

        var videoStreamUrl = isVideo
            ? $"/api/ContentReport/moderation/{contentId}/stream"
            : null;

        var isDeleted = isVideo
            ? first.Video!.IsDeleted
            : first.Comment!.IsDeleted;

        var items = reports
            .Select(report =>
                new ContentReportItemDto(
                    report.Id,
                    report.ReporterId,
                    report.Reporter.DisplayName,
                    report.Reason,
                    report.Status,
                    report.CreatedAtUtc))
            .ToList();

        return new ContentReportDetailDto(
            contentId,
            isVideo
                ? "Video"
                : "Comment",
            creatorId,
            creatorName,
            preview,
            videoStreamUrl,
            isDeleted,
            items);
    }

    public async Task<List<ContentReport>>
        GetByContentAsync(
            Guid contentId,
            bool isVideo,
            CancellationToken cancellationToken = default)
    {
        var query = _db.ContentReports
            .AsQueryable();

        query = isVideo
            ? query.Where(
                r => r.VideoId == contentId)
            : query.Where(
                r => r.CommentId == contentId);

        return await query
            .ToListAsync(cancellationToken);
    }

    private static ReportStatus ResolveGroupStatus(
        IEnumerable<ContentReport> reports)
    {
        if (reports.Any(
            r => r.Status ==
                 ReportStatus.Pending))
        {
            return ReportStatus.Pending;
        }

        if (reports.Any(
            r => r.Status ==
                 ReportStatus.Resolved))
        {
            return ReportStatus.Resolved;
        }

        return ReportStatus.Rejected;
    }

    public async Task<ContentReportStatsDto> GetStatsAsync(CancellationToken cancellationToken = default)
    {
        var stats = await _db.ContentReports
        .AsNoTracking()
        .GroupBy(r => r.Status)
        .Select(g => new
        {
            Status = g.Key,
            Count = g.Count()
        })
        .ToListAsync(cancellationToken);

        return new ContentReportStatsDto(
            Pending: stats
                .FirstOrDefault(x =>
                    x.Status == ReportStatus.Pending)
                ?.Count ?? 0,

            Resolved: stats
                .FirstOrDefault(x =>
                    x.Status == ReportStatus.Resolved)
                ?.Count ?? 0,

            Rejected: stats
                .FirstOrDefault(x =>
                    x.Status == ReportStatus.Rejected)
                ?.Count ?? 0);
    }

    public async Task<List<ContentReport>> GetByStatusAsync(ReportStatus status, int _page = 1, int _pageSize = 10, CancellationToken cancellationToken = default)
        => await _db.ContentReports
        .AsNoTracking()
        .Where(r => r.Status == status)
        .OrderByDescending(r => r.CreatedAtUtc)
        .Skip((_page - 1) * _pageSize)
        .Take(_pageSize)
        .ToListAsync(cancellationToken);

    public async Task<int> CountByStatusAsync(ReportStatus status, CancellationToken cancellationToken = default)
        => await _db.ContentReports.AsNoTracking().CountAsync(r => r.Status == status, cancellationToken);

    public async Task<int> CountAsync(CancellationToken cancellationToken = default)
        => await _db.ContentReports.AsNoTracking().CountAsync(cancellationToken);
}