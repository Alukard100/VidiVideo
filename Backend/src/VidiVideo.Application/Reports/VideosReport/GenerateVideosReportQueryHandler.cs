using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;

namespace VidiVideo.Application.Reports.VideosReport
{
    public sealed class GenerateVideosReportQueryHandler : IQueryHandler<GenerateVideosReportQuery, byte[]>
    {
        private readonly IVideoAnalyticsReportGenerator _videoAnalyticsReportGenerator;
        private readonly IVideoRepository _videoRepository;
        private readonly IVideoViewRepository _videoViewRepository;
        private readonly ILikeRepository _likeRepository;
        private readonly ICommentRepository _commentRepository;
        public GenerateVideosReportQueryHandler(IVideoAnalyticsReportGenerator videoAnalyticsReportGenerator, IVideoViewRepository videoViewRepository, IVideoRepository videoRepository, ILikeRepository likeRepository, ICommentRepository commentRepository)
        {
            _videoAnalyticsReportGenerator = videoAnalyticsReportGenerator;
            _videoViewRepository = videoViewRepository;
            _videoRepository = videoRepository;
            _likeRepository = likeRepository;
            _commentRepository = commentRepository;
        }

        public async Task<byte[]> HandleAsync(GenerateVideosReportQuery query, CancellationToken cancellationToken)
        {
            var totalVideos = _videoRepository.CountVideosFromAsync(query.From);
            var publishedVideos = _videoRepository.CountPublishedAsync(query.From);
            var publicVideos = _videoRepository.CountPublicAsync(query.From);
            var subscriberVideos = _videoRepository.CountSubscriberAsync(query.From);
            var totalViews = _videoViewRepository.CountTotalViewsAsync(query.From);
            var totalLikes = _likeRepository.CountTotalLikesAsync(query.From);
            var totalComments = _commentRepository.CountTotalCommentsAsync(query.From);
            var topVideos = _videoRepository.TopVideosAsync(query.From);


            await Task.WhenAll(
                totalVideos,
                publishedVideos,
                publicVideos,
                subscriberVideos,
                totalViews,
                totalLikes,
                totalComments);


            var rows = topVideos.Result.Select(v => new VideoAnalyticsRow(v.Caption, v.Creator.DisplayName, v.VideoViews.Count, v.Likes.Count, v.Comments.Count)).ToList();

            var dto = new VideoAnalyticsReportDto(query.From, totalVideos.Result, publishedVideos.Result, publicVideos.Result, subscriberVideos.Result, totalViews.Result, totalLikes.Result, totalComments.Result, rows);

            return _videoAnalyticsReportGenerator.Generate(dto);
        }
    }
}
