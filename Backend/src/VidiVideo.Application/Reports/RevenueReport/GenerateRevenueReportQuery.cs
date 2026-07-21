using VidiVideo.Application.Common;

namespace VidiVideo.Application.Reports.RevenueReport;

public sealed record GenerateRevenueReportQuery(DateTime? From = null) : IQuery<byte[]>;
