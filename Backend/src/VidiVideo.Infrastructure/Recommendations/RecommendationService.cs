using VidiVideo.Application.Abstractions.Recommendations;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;
using VidiVideo.Application.Recommendations;
using VidiVideo.Domain.Entities;
using VidiVideo.Domain.Enums;

namespace VidiVideo.Infrastructure.Recommendations;

public sealed class RecommendationService : IRecommendationService
{
    private readonly IVideoRepository _videoRepository;
    private readonly IUserRepository _userRepository;
    private readonly IPaymentRepository _paymentRepository;
    private readonly ILikeRepository _likeRepository;
    private readonly IFollowersRepository _followRepository;
    private readonly IVideoViewRepository _videoViewRepository;

    public RecommendationService(
        IVideoRepository videoRepository,
        IUserRepository userRepository,
        IPaymentRepository paymentRepository,
        ILikeRepository likeRepository,
        IFollowersRepository followersRepository,
        IVideoViewRepository videoViewRepository)
    {
        _videoRepository = videoRepository;
        _userRepository = userRepository;
        _paymentRepository = paymentRepository;
        _likeRepository = likeRepository;
        _followRepository = followersRepository;
        _videoViewRepository = videoViewRepository;
    }
    public async Task<PagedResult<RecommendedVideoDto>> GetRecommendedVideosAsync(Guid? userId, int page, int pageSize, CancellationToken cancellationToken)
    {
        if (!userId.HasValue)
            return await BuildPopularityRecommendations(page, pageSize, cancellationToken);

        var resolvedUserId = userId.Value;

        var currentUser =
            await _userRepository.GetProfileByIdAsync(resolvedUserId)
            ?? throw new NotFoundException("User doesn't exist.");

        var likedVideos =
            await _likeRepository.GetLikedVideosByUserAsync(resolvedUserId);

        var followedCreatorsIds =
            await _followRepository.GetFollowingCreatorIdsAsync(resolvedUserId);

        var subscribedCreatorIds =
            await _paymentRepository.GetActiveSubscribedCreatorIdsAsync(resolvedUserId);

        var videoViews =
            await _videoViewRepository.GetUserVideoViewsAsync(resolvedUserId);

        var hasMeaningfulViews =
            videoViews.Any(v => v.CompletionRate >= 0.25m);

        var isColdStart =
            likedVideos.Count == 0 &&
            followedCreatorsIds.Count == 0 &&
            subscribedCreatorIds.Count == 0 &&
            !hasMeaningfulViews;

        if (isColdStart)
            return await BuildPopularityRecommendations(page, pageSize, cancellationToken);

        var videos =
            await _videoRepository.GetRecommendationCandidatesAsync(resolvedUserId);

        var collaborativeScores =
            await _likeRepository.GetCollaborativeVideoScoreAsync(resolvedUserId);

        var categoryScores = likedVideos.GroupBy(v => v.CategoryId)
            .ToDictionary(
                group => group.Key,
                group => group.Count() * 4.0);

        var hashtagScores = likedVideos.SelectMany(v => v.VideoHashtags)
            .GroupBy(vh => vh.HashtagId)
            .ToDictionary(
                group => group.Key,
                group => group.Count() * 2.0);

        ApplyWatchAffinity(videoViews, categoryScores, hashtagScores);

        var candidates = videos
            .Select(video =>
            {
                var locked =
                    video.Visibility == VideoVisibility.SubscribersOnly &&
                    !subscribedCreatorIds.Contains(video.CreatorId);

                return new RecommendationCandidate
                {
                    Video = video,
                    IsLocked = locked
                };
            })
            .ToList();

        foreach (var candidate in candidates)
        {
            var popularityScore =
                CalculatePopularityScore(candidate.Video);

            var contentScore =
                CalculateContentScore(
                    candidate.Video,
                    currentUser,
                    subscribedCreatorIds,
                    followedCreatorsIds,
                    categoryScores,
                    hashtagScores);

            var collaborativeScore =
                collaborativeScores.TryGetValue(
                    candidate.Video.Id,
                    out var score) ? score : 0;

            candidate.Score = candidate.Score with
            {
                Popularity = popularityScore,
                Content = contentScore,
                Collaborative = collaborativeScore
            };
        }

        var minContent = candidates.Count == 0
            ? 0
            : candidates.Min(x => x.Score.Content);

        var maxContent = candidates.Count == 0
            ? 0
            : candidates.Max(x => x.Score.Content);

        var minCollaborative = candidates.Count == 0
            ? 0
            : candidates.Min(x => x.Score.Collaborative);

        var maxCollaborative = candidates.Count == 0
            ? 0
            : candidates.Max(x => x.Score.Collaborative);

        var minPopularity = candidates.Count == 0
            ? 0
            : candidates.Min(x => x.Score.Popularity);

        var maxPopularity = candidates.Count == 0
            ? 0
            : candidates.Max(x => x.Score.Popularity);

        foreach (var candidate in candidates)
        {
            candidate.Score = new RecommendationScore(
                Content: Normalize(
                    candidate.Score.Content,
                    minContent,
                    maxContent),

                Collaborative: Normalize(
                    candidate.Score.Collaborative,
                    minCollaborative,
                    maxCollaborative),

                Popularity: Normalize(
                    candidate.Score.Popularity,
                    minPopularity,
                    maxPopularity));
        }

        var ordered = candidates
        .OrderByDescending(x => x.Score.Total)
        .ToList();

        var total = ordered.Count;

        var paged = ordered
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToList();

        var items = paged
        .Select(candidate =>
        {
            var video = candidate.Video;

            return new RecommendedVideoDto(
                video.Id,
                video.Caption,
                candidate.IsLocked ? null : video.VideoUrl,
                video.ThumbnailUrl,
                video.CreatorId,
                video.Creator.DisplayName,
                video.Visibility.ToString(),
                video.Likes.Count,
                video.Comments.Count,
                video.VideoViews.Count,
                candidate.IsLocked,
                candidate.Score.Total);
        })
        .ToList();

        return new PagedResult<RecommendedVideoDto>(
            items,
            page,
            pageSize,
            total);
    }

    private static double CalculatePopularityScore(Video video)
    {
        var views = video.VideoViews.Count;
        var likes = video.Likes.Count;
        var comments = video.Comments.Count;

        var averageCompletionRate = video.VideoViews.Count == 0
            ? 0
            : (double)video.VideoViews.Average(v => v.CompletionRate);

        var age = DateTime.UtcNow - video.CreatedAtUtc;

        double recencyBonus = age.TotalDays switch
        {
            <= 1 => 30,
            <= 3 => 20,
            <= 7 => 10,
            <= 30 => 5,
            _ => 0
        };

        return
            views * 1 +
            likes * 5 +
            comments * 8 +
            averageCompletionRate * 20 +
            recencyBonus;
    }

    private static double CalculateContentScore(Video video, AppUser currentUser, HashSet<Guid> subscribedCreatorIds, HashSet<Guid> followedCreatorIds, Dictionary<Guid, double> categoryScores, Dictionary<Guid, double> hashtagScores)
    {
        double score = 0;

        if (currentUser.CountryId.HasValue &&
            video.Creator.CountryId.HasValue &&
            currentUser.CountryId == video.Creator.CountryId)
        {
            score += 3;
        }

        if (followedCreatorIds.Contains(video.CreatorId))
        {
            score += 20;
        }

        if (subscribedCreatorIds.Contains(video.CreatorId))
        {
            score += 40;
        }

        if (categoryScores.TryGetValue(video.CategoryId, out var categoryScore))
        {
            score += categoryScore;
        }

        foreach (var videoHashtag in video.VideoHashtags)
        {
            if (hashtagScores.TryGetValue(videoHashtag.HashtagId, out var hashtagScore))
            {
                score += hashtagScore;
            }
        }

        return score;
    }

    private static void ApplyWatchAffinity(IEnumerable<VideoView> videoViews, Dictionary<Guid, double> categoryScores, Dictionary<Guid, double> hashtagScores)
    {
        foreach (var view in videoViews)
        {
            var completion = (double)view.CompletionRate;

            double watchWeight = completion switch
            {
                >= 0.80 => 3,
                >= 0.50 => 2,
                >= 0.25 => 1,
                _ => 0
            };

            if (watchWeight == 0)
                continue;

            var viewedVideo = view.Video;

            if (categoryScores.TryGetValue(
            viewedVideo.CategoryId,
            out var categoryScore))
            {
                categoryScores[viewedVideo.CategoryId] =
                    categoryScore + watchWeight;
            }
            else
            {
                categoryScores[viewedVideo.CategoryId] =
                    watchWeight;
            }

            foreach (var videoHashtag in viewedVideo.VideoHashtags)
            {
                if (hashtagScores.TryGetValue(
                    videoHashtag.HashtagId,
                    out var hashtagScore))
                {
                    hashtagScores[videoHashtag.HashtagId] =
                        hashtagScore + watchWeight;
                }
                else
                {
                    hashtagScores[videoHashtag.HashtagId] =
                        watchWeight;
                }
            }
        }
    }

    private static double Normalize(double value, double min, double max)
    {
        if (max <= min) return 0;

        return (value - min) / (max - min);
    }

    private async Task<PagedResult<RecommendedVideoDto>> BuildPopularityRecommendations(int page, int pageSize, CancellationToken cancellationToken)
    {
        var videos =
            await _videoRepository.GetRecommendationCandidatesAsync(null);

        var candidates = videos
            .Where(v => v.Visibility == VideoVisibility.Public)
            .Select(video => new RecommendationCandidate
            {
                Video = video,
                IsLocked = false,
                Score = new RecommendationScore(
                    Content: 0,
                    Collaborative: 0,
                    Popularity: CalculatePopularityScore(video))
            })
            .ToList();

        var minPopularity = candidates.Count == 0
            ? 0
            : candidates.Min(x => x.Score.Popularity);

        var maxPopularity = candidates.Count == 0
            ? 0
            : candidates.Max(x => x.Score.Popularity);

        foreach (var candidate in candidates)
        {
            candidate.Score = new RecommendationScore(
                Content: 0,

                Collaborative: 0,

                Popularity: Normalize(
                    candidate.Score.Popularity,
                    minPopularity,
                    maxPopularity));
        }

        var ordered = candidates.OrderByDescending(x => x.Score.Popularity).ToList();

        var total = ordered.Count;

        var items = ordered.Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(candidate =>
            {
                var video = candidate.Video;

                return new RecommendedVideoDto(
                    video.Id,
                    video.Caption,
                    candidate.IsLocked ? null : video.VideoUrl,
                    video.ThumbnailUrl,
                    video.CreatorId,
                    video.Creator.DisplayName,
                    video.Visibility.ToString(),
                    video.Likes.Count,
                    video.Comments.Count,
                    video.VideoViews.Count,
                    false,
                    candidate.Score.Popularity);
            })
            .ToList();

        return new PagedResult<RecommendedVideoDto>(items, page, pageSize, total);
    }
}
