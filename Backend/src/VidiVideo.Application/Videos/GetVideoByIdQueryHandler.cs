using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;

namespace VidiVideo.Application.Videos
{
    public sealed class GetVideoByIdQueryHandler : IQueryHandler<GetVideoByIdQuery, VideoDto>
    {
        private readonly IVideoRepository _repo;
        private readonly IPaymentRepository _paymentRepository;
        private readonly ILikeRepository _likeRepository;
        private readonly ICurrentUser _currentUser;
        private readonly IVideoAccessService _videoAccessService;
        public GetVideoByIdQueryHandler(IVideoRepository repo, IPaymentRepository paymentRepository, ILikeRepository likeRepository, ICurrentUser currentUser, IVideoAccessService videoAccessService)
        {
            _repo = repo;
            _paymentRepository = paymentRepository;
            _likeRepository = likeRepository;
            _currentUser = currentUser;
            _videoAccessService = videoAccessService;

        }

        public async Task<VideoDto> HandleAsync(GetVideoByIdQuery query, CancellationToken cancellationToken)
        {
            var video = await _repo.GetVideoByIdAsync(query.videoId, cancellationToken) ?? throw new NotFoundException("Video doesn't exist");

            var userId = _currentUser.UserId;

            var access = await _videoAccessService.GetAccessAsync(userId, video, cancellationToken);

            if (!access.IsVisible)
                throw new NotFoundException("Video doesn't exist");

            var streamUrl = access.IsLocked ? null : $"/api/Video/{video.Id}/stream";

            var isLiked = userId.HasValue &&
                await _likeRepository.IsLikedByCurrentUser(video.Id, userId.Value);

            var canEdit = userId.HasValue && video.CreatorId == userId.Value;

            return new VideoDto(
                video.Id,
                video.Caption,
                streamUrl,
                video.ThumbnailUrl,
                video.CreatorId,
                video.Creator.DisplayName,
                video.Creator.AvatarUrl,
                video.CategoryId,
                video.Category.Name,
                video.IsPublished,
                video.Visibility,
                video.Likes.Count,
                video.Comments.Count,
                video.VideoViews.Count,
                access.IsLocked,
                isLiked,
                access.IsOwner,
                video.VideoHashtags
                    .Select(vh => vh.Hashtag.Name)
                    .ToList()
            );
        }
    }
}
