using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VidiVideo.Application.Common;
using VidiVideo.Application.SearchHistories;

namespace VidiVideo.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class SearchHistoryController : ControllerBase
{
    private readonly ICommandHandler<CreateSearchHistoryCommand, Guid> _createHandler;
    private readonly ICommandHandler<DeleteSearchHistoryCommand, bool> _deleteHandler;
    private readonly ICommandHandler<ClearSearchHistoryCommand, bool> _clearHandler;
    private readonly IQueryHandler<GetSearchHistoryQuery, PagedResult<SearchHistoryDto>> _getHandler;
    public SearchHistoryController(
        ICommandHandler<CreateSearchHistoryCommand, Guid> createHandler,
        ICommandHandler<DeleteSearchHistoryCommand, bool> deleteHandler,
        ICommandHandler<ClearSearchHistoryCommand, bool> clearHandler,
        IQueryHandler<GetSearchHistoryQuery,
            PagedResult<SearchHistoryDto>> getHandler)
    {
        _createHandler = createHandler;
        _deleteHandler = deleteHandler;
        _clearHandler = clearHandler;
        _getHandler = getHandler;
    }

    [Authorize]
    [HttpPost]
    public async Task<IActionResult> Create(
        CreateSearchHistoryCommand command,
        CancellationToken cancellation)
    {
        return Ok(await _createHandler.HandleAsync(command, cancellation));
    }

    [Authorize]
    [HttpGet("history")]
    public async Task<IActionResult> Get(
        [FromQuery] GetSearchHistoryQuery query,
        CancellationToken cancellation)
    {
        return Ok(await _getHandler.HandleAsync(query, cancellation));
    }

    [Authorize]
    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(
        Guid id,
        CancellationToken cancellation)
    {
        return Ok(await _deleteHandler.HandleAsync(
            new DeleteSearchHistoryCommand(id),
            cancellation));
    }

    [Authorize]
    [HttpDelete("clear/{userId:guid}")]
    public async Task<IActionResult> Clear(
        Guid userId,
        CancellationToken cancellation)
    {
        return Ok(await _clearHandler.HandleAsync(
            new ClearSearchHistoryCommand(userId),
            cancellation));
    }


}
