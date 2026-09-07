using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;

namespace VidiVideo.Application.Videos.VideoFile;

public sealed class GetVideoStreamQueryHandler : IQueryHandler<GetVideoStreamQuery, VideoStreamResult>
{
    private readonly IVideoRepository _videoRepository;
    private readonly IVideoStorageService _videoStorageService;
    private readonly ICurrentUser _currentUser;
    private readonly IVideoAccessService _videoAccessService;

    public GetVideoStreamQueryHandler(
        IVideoRepository videoRepository,
        IVideoStorageService videoStorageService,
        ICurrentUser currentUser,
        IVideoAccessService videoAccessService)
    {
        _videoRepository = videoRepository;
        _videoStorageService = videoStorageService;
        _currentUser = currentUser;
        _videoAccessService = videoAccessService;
    }

    public async Task<VideoStreamResult> HandleAsync(GetVideoStreamQuery query, CancellationToken cancellationToken)
    {
        var video =
            await _videoRepository.GetVideoForStreamingAsync(query.VideoId, cancellationToken)
            ?? throw new NotFoundException("Video doesn't exist.");

        var userId = _currentUser.UserId;

        var access = await _videoAccessService.GetAccessAsync(userId, video, cancellationToken);
        if (!access.IsVisible) throw new NotFoundException("Video doesn't exist");
        if (access.IsLocked) throw new ForbiddenException("An active subscription is required to access this video");

        var stream = await _videoStorageService.OpenReadAsync(video.VideoUrl, cancellationToken);

        var contentType = _videoStorageService.GetContentType(video.VideoUrl);

        return new VideoStreamResult(stream, contentType);
    }
}
