using VidiVideo.Application.Common;

namespace VidiVideo.Application.Reports.VideosReport;

public sealed record GenerateVideosReportQuery(DateTime? From = null) : IQuery<byte[]>;
