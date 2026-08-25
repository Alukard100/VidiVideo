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
            var totalVideos = await _videoRepository.CountVideosFromAsync(query.From, cancellationToken);
            var publishedVideos = await _videoRepository.CountPublishedAsync(query.From, cancellationToken);
            var publicVideos = await _videoRepository.CountPublicAsync(query.From, cancellationToken);
            var subscriberVideos = await _videoRepository.CountSubscriberAsync(query.From, cancellationToken);
            var totalViews = await _videoViewRepository.CountTotalViewsAsync(query.From);
            var totalLikes = await _likeRepository.CountTotalLikesAsync(query.From);
            var totalComments = await _commentRepository.CountTotalCommentsAsync(query.From);
            var topVideos = await _videoRepository.TopVideosAsync(query.From, cancellationToken);



            var rows = topVideos.Select(v => new VideoAnalyticsRow(v.Caption, v.Creator.DisplayName, v.VideoViews.Count, v.Likes.Count, v.Comments.Count)).ToList();

            var dto = new VideoAnalyticsReportDto(query.From, totalVideos, publishedVideos, publicVideos, subscriberVideos, totalViews, totalLikes, totalComments, rows);

            return _videoAnalyticsReportGenerator.Generate(dto);
        }
    }
}
