using VidiVideo.Application.Reports.VideosReport;

namespace VidiVideo.Application.Abstractions
{
    public interface IVideoAnalyticsReportGenerator
    {
        byte[] Generate(VideoAnalyticsReportDto dto);
    }
}
