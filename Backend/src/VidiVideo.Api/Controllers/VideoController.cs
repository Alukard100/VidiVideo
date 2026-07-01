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

    public VideoController(ICommandHandler<CreateVideoCommand, Guid> videoHandler, ICommandHandler<CreateThumbnailCommand, string> thumbnailFileHandler, ICommandHandler<UploadVideoCommand, string> videoFileHandler)
    {
        _createVideoHandler = videoHandler;
        _thumbnailFileHandler = thumbnailFileHandler;
        _videoFileHandler = videoFileHandler;
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

}
