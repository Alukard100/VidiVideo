using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
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
    [HttpPost("create")]
    public async Task<IActionResult> Create([FromBody] VideoCreateRequest request, CancellationToken cancellation)
    {
        var command = new CreateVideoCommand(request.CategoryId, request.Caption, request.VideoUrl, request.ThumbnailUrl, request.Visibility, request.IsPublished);

        var videoId = await _createVideoHandler.HandleAsync(command, cancellation);

        return Ok(videoId);
    }

    [Authorize]
    [HttpPost("upload-video")]
    [RequestSizeLimit(75497472)]
    public async Task<IActionResult> UploadVideo(IFormFile formFile, CancellationToken cancellation)
    {
        var command = new UploadVideoCommand(formFile.OpenReadStream(), formFile.FileName);

        string videoUrl = await _videoFileHandler.HandleAsync(command, cancellation);

        return Ok(new
        {
            videoUrl
        });
    }

    [Authorize]
    [HttpPost("upload-thumbnail")]
    [RequestSizeLimit(5242880)]
    public async Task<IActionResult> UploadImage(IFormFile formFile, CancellationToken cancellation)
    {
        var command = new CreateThumbnailCommand(formFile.OpenReadStream(), formFile.FileName);

        string thumbnailUrl = await _thumbnailFileHandler.HandleAsync(command, cancellation);

        return Ok(new
        {
            thumbnailUrl
        });
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
        var command = new UpdateVideoCommand(request.VideoId, request.CategoryId, request.Caption, request.ThumbnailUrl, request.Visibility, request.IsPublished);

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
