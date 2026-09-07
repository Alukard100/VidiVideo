using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.DTOs;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Domain.Entities;

namespace VidiVideo.Infrastructure.AccessValidators;

public class VideoAccessService : IVideoAccessService
{
    private readonly IPaymentRepository _paymentRepository;
    public VideoAccessService(IPaymentRepository paymentRepository)
    {
        _paymentRepository = paymentRepository;
    }

    public async Task<VideoAccessResult> GetAccessAsync(Guid? userId, Video video, CancellationToken cancellationToken)
    {
        var isOwner = userId.HasValue && video.CreatorId == userId.Value;

        if (video.IsDeleted)
        {
            return new VideoAccessResult(
                IsVisible: false,
                IsLocked: false,
                IsOwner: isOwner);
        }

        if (!video.IsPublished && !isOwner)
        {
            return new VideoAccessResult(
                IsVisible: false,
                IsLocked: false,
                IsOwner: false);
        }

        if (isOwner)
        {
            return new VideoAccessResult(
                IsVisible: true,
                IsLocked: false,
                IsOwner: true);
        }

        var requiresSubscription =
            video.Visibility == Domain.Enums.VideoVisibility.SubscribersOnly ||
            (
                video.Visibility == Domain.Enums.VideoVisibility.Public &&
                video.EarlyAccessUntilUtc.HasValue &&
                video.EarlyAccessUntilUtc.Value > DateTime.UtcNow
            );

        if (!requiresSubscription)
        {
            return new VideoAccessResult(
                IsVisible: true,
                IsLocked: false,
                IsOwner: false);
        }

        if (!userId.HasValue)
        {
            return new VideoAccessResult(
                IsVisible: true,
                IsLocked: true,
                IsOwner: false);
        }

        var hasSubscription = await _paymentRepository.HasActiveSubscriptionAsync(userId.Value, video.CreatorId);

        return new VideoAccessResult(
                IsVisible: true,
                IsLocked: !hasSubscription,
                IsOwner: false);

    }
}
