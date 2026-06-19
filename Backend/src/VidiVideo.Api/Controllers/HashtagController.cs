using Microsoft.AspNetCore.Mvc;
using VidiVideo.Application.Common;
using VidiVideo.Application.Hashtags;

namespace VidiVideo.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class HashtagController : ControllerBase
{
    private readonly ICommandHandler<CreateHashtagCommand, Guid> _createHandler;
    private readonly IQueryHandler<GetHashtagsQuery, List<HashtagDto>> _getHashtagsHandler;
    private readonly IQueryHandler<GetHashtagByIdQuery, HashtagDto> _getHashtagByIdHandler;
    private readonly ICommandHandler<DeleteHashtagCommand, bool> _deleteHandler;

    public HashtagController(ICommandHandler<CreateHashtagCommand, Guid> createHandler, IQueryHandler<GetHashtagsQuery, List<HashtagDto>> getHashtagsHandler, IQueryHandler<GetHashtagByIdQuery, HashtagDto> getHashtagByIdHandler, ICommandHandler<DeleteHashtagCommand, bool> deleteHandler)
    {
        _createHandler = createHandler;
        _getHashtagsHandler = getHashtagsHandler;
        _getHashtagByIdHandler = getHashtagByIdHandler;
        _deleteHandler = deleteHandler;
    }

    [HttpPost("create")]
    public async Task<IActionResult> Create([FromBody] CreateHashtagRequest request, CancellationToken cancellationToken)
    {
        var command = new CreateHashtagCommand(request.Name);

        var hashtagId = await _createHandler.HandleAsync(command, cancellationToken);

        return Ok(hashtagId);
    }

    [HttpGet("{Id:Guid}")]
    public async Task<IActionResult> GetHashtag(Guid Id, CancellationToken cancellationToken)
    {
        var query = new GetHashtagByIdQuery(Id);

        var hashtag = await _getHashtagByIdHandler.HandleAsync(query, cancellationToken);

        return Ok(hashtag);
    }

    [HttpGet("getall")]
    public async Task<IActionResult> GetAll(CancellationToken cancellationToken)
    {
        var result = await _getHashtagsHandler.HandleAsync(new GetHashtagsQuery(), cancellationToken);

        return Ok(result);
    }

    [HttpDelete("{hashtagId:guid}")]
    public async Task<IActionResult> DeleteHashtag(Guid hashtagId, CancellationToken cancellationToken)
    {
        var command = new DeleteHashtagCommand(hashtagId);

        var result = await _deleteHandler.HandleAsync(command, cancellationToken);

        return Ok(result);
    }


}
