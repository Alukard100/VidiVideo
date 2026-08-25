using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;
using VidiVideo.Domain.Enums;

namespace VidiVideo.Application.Payments.Refunds;

public sealed class RejectRefundRequestCommandHandler
    : ICommandHandler<RejectRefundRequestCommand, bool>
{
    private readonly IRefundRequestRepository _refundRepository;
    private readonly ICurrentUser _currentUser;
    private readonly IUnitOfWork _unitOfWork;

    public RejectRefundRequestCommandHandler(
        IRefundRequestRepository refundRepository,
        ICurrentUser currentUser,
        IUnitOfWork unitOfWork)
    {
        _refundRepository = refundRepository;
        _currentUser = currentUser;
        _unitOfWork = unitOfWork;
    }

    public async Task<bool> HandleAsync(
        RejectRefundRequestCommand command,
        CancellationToken cancellationToken)
    {
        var reviewerId = _currentUser.UserId
            ?? throw new UnauthorizedException(
                "Must be logged in.");

        var request =
            await _refundRepository.GetByIdAsync(
                command.RefundRequestId,
                cancellationToken)
            ?? throw new NotFoundException(
                "Refund request doesn't exist.");

        if (request.Status != RefundRequestStatus.Pending)
            throw new ValidationException(
                "Refund request has already been reviewed.");

        request.Reject(reviewerId);

        await _unitOfWork.SaveChangesAsync(
            cancellationToken);

        return true;
    }
}