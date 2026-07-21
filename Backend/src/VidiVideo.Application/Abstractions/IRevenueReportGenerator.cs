using VidiVideo.Application.Reports.RevenueReport;

namespace VidiVideo.Application.Abstractions
{
    public interface IRevenueReportGenerator
    {
        byte[] Generate(RevenueAnalyticsDto dto);

    }
}
