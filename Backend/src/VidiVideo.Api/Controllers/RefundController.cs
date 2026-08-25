using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VidiVideo.Application.Common;
using VidiVideo.Application.Payments.Refunds;
using VidiVideo.Application.Users.Activities;
using VidiVideo.Domain.Constants;

namespace VidiVideo.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class RefundController : ControllerBase
{
    private readonly ICommandHandler<CreateRefundRequestCommand, Guid> _createHandler;
    private readonly ICommandHandler<ApproveRefundRequestCommand, bool> _approveHandler;
    private readonly ICommandHandler<RejectRefundRequestCommand, bool> _rejectHandler;
    private readonly IQueryHandler<GetAllRefundRequestsQuery, PagedResult<RefundRequestDto>> _queryHandler;

    public RefundController(ICommandHandler<CreateRefundRequestCommand, Guid> createHandler, ICommandHandler<ApproveRefundRequestCommand, bool> approveHandler, ICommandHandler<RejectRefundRequestCommand, bool> rejectHandler, IQueryHandler<GetAllRefundRequestsQuery, PagedResult<RefundRequestDto>> queryHandler)
    {
        _createHandler = createHandler;
        _rejectHandler = rejectHandler;
        _queryHandler = queryHandler;
        _approveHandler = approveHandler;
    }

    [Authorize]
    [HttpPost("request")]
    public async Task<IActionResult> RequestRefund(
        [FromBody] CreateRefundRequestCommand command,
        CancellationToken cancellationToken)
    {
        return Ok(
            await _createHandler.HandleAsync(
                command,
                cancellationToken));
    }

    [Authorize(Roles = $"{AppRoles.Admin},{AppRoles.SuperAdmin}")]
    [HttpGet]
    public async Task<IActionResult> GetAll(
        [FromQuery] GetAllRefundRequestsQuery query,
        CancellationToken cancellationToken)
    {
        return Ok(
            await _queryHandler.HandleAsync(
                query,
                cancellationToken));
    }

    [Authorize(Roles = $"{AppRoles.Admin},{AppRoles.SuperAdmin}")]
    [HttpPatch("{refundRequestId:guid}/approve")]
    public async Task<IActionResult> Approve(
        Guid refundRequestId,
        CancellationToken cancellationToken)
    {
        return Ok(
            await _approveHandler.HandleAsync(
                new ApproveRefundRequestCommand(
                    refundRequestId),
                cancellationToken));
    }

    [Authorize(Roles = $"{AppRoles.Admin},{AppRoles.SuperAdmin}")]
    [HttpPatch("{refundRequestId:guid}/reject")]
    public async Task<IActionResult> Reject(
        Guid refundRequestId,
        CancellationToken cancellationToken)
    {
        return Ok(
            await _rejectHandler.HandleAsync(
                new RejectRefundRequestCommand(
                    refundRequestId),
                cancellationToken));
    }


}
