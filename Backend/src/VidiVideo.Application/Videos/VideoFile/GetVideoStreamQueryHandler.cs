using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;
using VidiVideo.Domain.Enums;

namespace VidiVideo.Application.Videos.VideoFile;

public sealed class GetVideoStreamQueryHandler : IQueryHandler<GetVideoStreamQuery, VideoStreamResult>
{
    private readonly IVideoRepository _videoRepository;
    private readonly IVideoStorageService _videoStorageService;
    private readonly IPaymentRepository _paymentRepository;
    private readonly ICurrentUser _currentUser;

    public GetVideoStreamQueryHandler(
        IVideoRepository videoRepository,
        IVideoStorageService videoStorageService,
        IPaymentRepository paymentRepository,
        ICurrentUser currentUser)
    {
        _videoRepository = videoRepository;
        _videoStorageService = videoStorageService;
        _paymentRepository = paymentRepository;
        _currentUser = currentUser;
    }

    public async Task<VideoStreamResult> HandleAsync(GetVideoStreamQuery query, CancellationToken cancellationToken)
    {
        var video =
            await _videoRepository.GetVideoForStreamingAsync(query.VideoId, cancellationToken)
            ?? throw new NotFoundException("Video doesn't exist.");

        if (video.IsDeleted)
            throw new NotFoundException("Video doesn't exist.");

        var userId = _currentUser.UserId;

        var isOwner =
            userId.HasValue &&
            video.CreatorId == userId.Value;

        if (!video.IsPublished && !isOwner)
            throw new NotFoundException("Video doesn't exist");

        if (video.Visibility == VideoVisibility.SubscribersOnly)
        {
            if (!isOwner)
            {
                if (!userId.HasValue)
                    throw new UnauthorizedException("Must be logged in.");

                var hasSubscription = await _paymentRepository.HasActiveSubscriptionAsync(userId.Value, video.CreatorId);

                if (!hasSubscription)
                    throw new ForbiddenException("Subscription required");
            }
        }

        var stream = await _videoStorageService.OpenReadAsync(video.VideoUrl, cancellationToken);

        var contentType = _videoStorageService.GetContentType(video.VideoUrl);

        return new VideoStreamResult(stream, contentType);
    }
}
