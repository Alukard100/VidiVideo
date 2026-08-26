using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;

namespace VidiVideo.Application.Payments.PayPal;

public sealed class
    CompletePayPalOnboardingCommandHandler
    : ICommandHandler<
        CompletePayPalOnboardingCommand,
        bool>
{
    private readonly ICurrentUser _currentUser;
    private readonly IUserRepository _userRepository;
    private readonly IPayPalService _payPalService;
    private readonly IUnitOfWork _unitOfWork;

    public CompletePayPalOnboardingCommandHandler(
        ICurrentUser currentUser,
        IUserRepository userRepository,
        IPayPalService payPalService,
        IUnitOfWork unitOfWork)
    {
        _currentUser = currentUser;
        _userRepository = userRepository;
        _payPalService = payPalService;
        _unitOfWork = unitOfWork;
    }

    public async Task<bool> HandleAsync(
        CompletePayPalOnboardingCommand command,
        CancellationToken cancellationToken)
    {
        var userId =
            _currentUser.UserId
            ?? throw new UnauthorizedException(
                "Must be logged in.");

        var user =
            await _userRepository
                .GetByIdAsync(userId)
            ?? throw new NotFoundException(
                "User doesn't exist.");

        var status =
            await _payPalService
                .GetMerchantStatusByTrackingIdAsync(
                    userId);

        if (status is null)
        {
            throw new ValidationException(
                "PayPal onboarding has not been completed.");
        }

        if (!status.PaymentsReceivable)
        {
            throw new ValidationException(
                "PayPal account is not ready to receive payments.");
        }

        if (!status.PrimaryEmailConfirmed)
        {
            throw new ValidationException(
                "PayPal email address must be confirmed.");
        }

        user.ConnectPayPal(
            status.MerchantId);

        await _unitOfWork.SaveChangesAsync(
            cancellationToken);

        return true;
    }
}