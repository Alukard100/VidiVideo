using Microsoft.AspNetCore.Mvc;
using VidiVideo.Application.Common;
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

    public VideoController(ICommandHandler<CreateVideoCommand, Guid> videoHandler, ICommandHandler<CreateThumbnailCommand, string> thumbnailFileHandler, ICommandHandler<UploadVideoCommand, string> videoFileHandler, IQueryHandler<GetVideoByIdQuery, VideoDto> videoByIdQuery, IQueryHandler<GetVideosQuery, PagedResult<VideoSummaryDto>> videosQuery, ICommandHandler<DeleteVideoCommand, bool> deleteHandler, ICommandHandler<UpdateVideoCommand, Guid> updateHandler)
    {
        _createVideoHandler = videoHandler;
        _thumbnailFileHandler = thumbnailFileHandler;
        _videoFileHandler = videoFileHandler;
        _videoByIdQuery = videoByIdQuery;
        _videosQuery = videosQuery;
        _deleteHandler = deleteHandler;
        _updateHandler = updateHandler;
    }

    [HttpPost("create")]
    public async Task<IActionResult> Create([FromBody] VideoCreateRequest request, CancellationToken cancellation)
    {
        var command = new CreateVideoCommand(request.creatorId, request.categoryId, request.caption, request.videoUrl, request.thumbnailUrl, request.visibility, request.isPublished);

        var videoId = await _createVideoHandler.HandleAsync(command, cancellation);

        return Ok(videoId);
    }

    [HttpPost("upload-video")]
    [RequestSizeLimit(524288000)]
    public async Task<IActionResult> UploadVideo(IFormFile formFile, CancellationToken cancellation)
    {
        var command = new UploadVideoCommand(formFile.OpenReadStream(), formFile.FileName);

        string result = await _videoFileHandler.HandleAsync(command, cancellation);

        return Ok(result);
    }

    [HttpPost("upload-thumbnail")]
    [RequestSizeLimit(5242880)]
    public async Task<IActionResult> UploadImage(IFormFile formFile, CancellationToken cancellation)
    {
        var command = new CreateThumbnailCommand(formFile.OpenReadStream(), formFile.FileName);

        string result = await _thumbnailFileHandler.HandleAsync(command, cancellation);

        return Ok(result);
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

    [HttpDelete("{videoId:guid}")]
    public async Task<IActionResult> DeleteVideo(Guid videoId, CancellationToken cancellationToken)
    {
        var command = new DeleteVideoCommand(videoId);

        var result = await _deleteHandler.HandleAsync(command, cancellationToken);

        return Ok(result);
    }

    [HttpPatch("update")]
    public async Task<IActionResult> UpdateVideo([FromBody] VideoUpdateRequest request, CancellationToken cancellationToken)
    {
        var command = new UpdateVideoCommand(request.videoId, request.categoryId, request.caption, request.thumbnailUrl, request.visibility, request.isPublished);

        var result = await _updateHandler.HandleAsync(command, cancellationToken);

        return Ok(result);
    }
}
