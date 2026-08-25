using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;
using VidiVideo.Domain.Entities;

namespace VidiVideo.Application.Users.Activities;

public sealed class CreateRefundRequestCommandHandler : ICommandHandler<CreateRefundRequestCommand, Guid>
{
    private readonly IPaymentRepository _paymentRepository;
    private readonly IRefundRequestRepository _refundRepository;
    private readonly ICurrentUser _currentUser;
    private readonly IUnitOfWork _unitOfWork;
    private readonly IUserRepository _userRepository;

    public CreateRefundRequestCommandHandler(IPaymentRepository paymentRepository, IRefundRequestRepository refundRepository, ICurrentUser currentUser, IUnitOfWork unitOfWork, IUserRepository userRepository)
    {
        _paymentRepository = paymentRepository;
        _refundRepository = refundRepository;
        _currentUser = currentUser;
        _unitOfWork = unitOfWork;
        _userRepository = userRepository;
    }

    public async Task<Guid> HandleAsync(CreateRefundRequestCommand command, CancellationToken cancellationToken)
    {
        var userId = _currentUser.UserId ?? throw new UnauthorizedException("Must be logged in");

        if (!await _userRepository.ExistsByIdAsync(command.CreatorId))
            throw new NotFoundException("Creator doesn't exist");

        var payment = await _paymentRepository.GetCompletedSubscriptionPaymentAsync(userId, command.CreatorId, cancellationToken) ?? throw new NotFoundException("Completed subscription was not found");

        if (await _refundRepository.HasPendingRequestAsync(payment.Id, cancellationToken))
            throw new ConflictException("A refund request already exists for this payment");

        var request = new RefundRequest(payment.Id);

        await _refundRepository.AddAsync(request, cancellationToken);

        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return request.Id;

    }
}
