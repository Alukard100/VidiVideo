using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;

namespace VidiVideo.Application.Videos.VideoFile;

public sealed class GetModerationVideoStreamQueryHandler : IQueryHandler<GetModerationVideoStreamQuery, VideoStreamResult>
{
    private readonly IVideoRepository _videoRepository;
    private readonly IVideoStorageService _videoStorageService;
    public GetModerationVideoStreamQueryHandler(IVideoRepository videoRepository, IVideoStorageService videoStorageService)
    {
        _videoRepository = videoRepository;
        _videoStorageService = videoStorageService;
    }

    public async Task<VideoStreamResult> HandleAsync(GetModerationVideoStreamQuery query, CancellationToken cancellationToken)
    {
        var video =
            await _videoRepository.GetVideoForStreamingAsync(query.VideoId, cancellationToken)
            ?? throw new NotFoundException("Video doesn't exist.");


        var stream = await _videoStorageService.OpenReadAsync(video.VideoUrl, cancellationToken);

        var contentType = _videoStorageService.GetContentType(video.VideoUrl);

        return new VideoStreamResult(stream, contentType);
    }
}
