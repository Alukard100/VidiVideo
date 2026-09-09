using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VidiVideo.Api.Requests;
using VidiVideo.Application.Common;
using VidiVideo.Application.Recommendations;
using VidiVideo.Application.Videos;
using VidiVideo.Application.Videos.Thumbnails;
using VidiVideo.Application.Videos.VideoFile;

namespace VidiVideo.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class VideoController : ControllerBase
{
    private readonly ICommandHandler<CreateVideoCommand, Guid> _createVideoHandler;
    private readonly ICommandHandler<CreateThumbnailCommand, string> _thumbnailFileHandler;
    private readonly ICommandHandler<UploadVideoCommand, string> _videoFileHandler;
    private readonly IQueryHandler<GetVideoByIdQuery, VideoDto> _videoByIdQuery;
    private readonly IQueryHandler<GetVideosQuery, PagedResult<VideoSummaryDto>> _videosQuery;
    private readonly ICommandHandler<DeleteVideoCommand, bool> _deleteHandler;
    private readonly ICommandHandler<UpdateVideoCommand, Guid> _updateHandler;
    private readonly IQueryHandler<GetRecommendedVideosQuery, PagedResult<VideoFeedDto>> _recommendedHandler;
    private readonly IQueryHandler<GetFollowingFeedQuery, PagedResult<VideoFeedDto>> _followingHandler;
    private readonly IQueryHandler<GetVideoStreamQuery, VideoStreamResult> _videoStreamHandler;

    public VideoController(ICommandHandler<CreateVideoCommand, Guid> videoHandler, ICommandHandler<CreateThumbnailCommand, string> thumbnailFileHandler, ICommandHandler<UploadVideoCommand, string> videoFileHandler, IQueryHandler<GetVideoByIdQuery, VideoDto> videoByIdQuery, IQueryHandler<GetVideosQuery, PagedResult<VideoSummaryDto>> videosQuery, ICommandHandler<DeleteVideoCommand, bool> deleteHandler, ICommandHandler<UpdateVideoCommand, Guid> updateHandler, IQueryHandler<GetRecommendedVideosQuery, PagedResult<VideoFeedDto>> recommendedHandler, IQueryHandler<GetFollowingFeedQuery, PagedResult<VideoFeedDto>> followingHandler, IQueryHandler<GetVideoStreamQuery, VideoStreamResult> videoStreamHandler)
    {
        _createVideoHandler = videoHandler;
        _thumbnailFileHandler = thumbnailFileHandler;
        _videoFileHandler = videoFileHandler;
        _videoByIdQuery = videoByIdQuery;
        _videosQuery = videosQuery;
        _deleteHandler = deleteHandler;
        _updateHandler = updateHandler;
        _recommendedHandler = recommendedHandler;
        _followingHandler = followingHandler;
        _videoStreamHandler = videoStreamHandler;
    }

    [Authorize]
    [HttpPost("create-video")]
    [Consumes("multipart/form-data")]
    [RequestSizeLimit(83886080)] //80MB total
    public async Task<IActionResult> Create([FromForm] VideoCreateRequest request, CancellationToken cancellationToken)
    {
        if (request.VideoFile is null || request.VideoFile.Length == 0)
            return BadRequest("Video file is required");

        if (request.ThumbnailFile is null || request.ThumbnailFile.Length == 0)
            return BadRequest("Thumbnail file is required");

        await using var videoStream = request.VideoFile.OpenReadStream();
        await using var thumbnailStream = request.ThumbnailFile.OpenReadStream();

        var videoCommand = new UploadVideoCommand(videoStream, request.VideoFile.FileName);
        var videoUrl = await _videoFileHandler.HandleAsync(videoCommand, cancellationToken);

        var thumbnailCommand = new CreateThumbnailCommand(thumbnailStream, request.ThumbnailFile.FileName);
        var thumbnailUrl = await _thumbnailFileHandler.HandleAsync(thumbnailCommand, cancellationToken);

        var command = new CreateVideoCommand(request.CategoryId, request.Caption, videoUrl, thumbnailUrl, request.Visibility, request.IsPublished, request.EarlyAccessDays);

        var videoId = await _createVideoHandler.HandleAsync(command, cancellationToken);

        return Ok(videoId);
    }

    [HttpGet("getall")]
    public async Task<IActionResult> GetAll([FromQuery] GetVideosQuery query, CancellationToken cancellationToken)
    {
        var result = await _videosQuery.HandleAsync(query, cancellationToken);
        return Ok(result);
    }

    [HttpGet("{Id:guid}")]
    public async Task<IActionResult> GetVideo(Guid Id, CancellationToken cancellationToken)
    {
        var query = new GetVideoByIdQuery(Id);

        var video = await _videoByIdQuery.HandleAsync(query, cancellationToken);

        return Ok(video);
    }

    [Authorize]
    [HttpDelete("{videoId:guid}")]
    public async Task<IActionResult> DeleteVideo(Guid videoId, CancellationToken cancellationToken)
    {
        var command = new DeleteVideoCommand(videoId);

        var result = await _deleteHandler.HandleAsync(command, cancellationToken);

        return Ok(result);
    }

    [Authorize]
    [HttpPatch("update")]
    public async Task<IActionResult> UpdateVideo([FromBody] VideoUpdateRequest request, CancellationToken cancellationToken)
    {
        var command = new UpdateVideoCommand(request.VideoId, request.CategoryId, request.Caption, request.Visibility, request.IsPublished);

        var result = await _updateHandler.HandleAsync(command, cancellationToken);

        return Ok(result);
    }

    [HttpGet("recommended")]
    public async Task<IActionResult> Recommended(
    [FromQuery] GetRecommendedVideosQuery query,
    CancellationToken cancellationToken)
    {
        var result = await _recommendedHandler.HandleAsync(
            query,
            cancellationToken);

        return Ok(result);
    }

    [Authorize]
    [HttpGet("following")]
    public async Task<IActionResult> Following(
    [FromQuery] GetFollowingFeedQuery query,
    CancellationToken cancellationToken)
    {
        var result = await _followingHandler.HandleAsync(
            query,
            cancellationToken);

        return Ok(result);
    }

    [HttpGet("{videoId:guid}/stream")]
    public async Task<IActionResult> StreamVideo(
    Guid videoId,
    CancellationToken cancellationToken)
    {
        var query =
            new GetVideoStreamQuery(videoId);

        var result =
            await _videoStreamHandler.HandleAsync(
                query,
                cancellationToken);

        return File(
            result.Stream,
            result.ContentType,
            enableRangeProcessing: true);
    }
}
