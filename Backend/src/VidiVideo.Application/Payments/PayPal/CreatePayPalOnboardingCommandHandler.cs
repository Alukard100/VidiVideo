using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;

namespace VidiVideo.Application.Payments.PayPal;

public sealed class
    CreatePayPalOnboardingCommandHandler
    : ICommandHandler<
        CreatePayPalOnboardingCommand,
        PayPalOnboardingResult>
{
    private readonly ICurrentUser _currentUser;
    private readonly IUserRepository _userRepository;
    private readonly IPayPalService _payPalService;

    public CreatePayPalOnboardingCommandHandler(
        ICurrentUser currentUser,
        IUserRepository userRepository,
        IPayPalService payPalService)
    {
        _currentUser = currentUser;
        _userRepository = userRepository;
        _payPalService = payPalService;
    }

    public async Task<PayPalOnboardingResult>
        HandleAsync(
            CreatePayPalOnboardingCommand command,
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

        if (user.HasConnectedPayPal)
        {
            throw new ConflictException(
                "PayPal is already connected.");
        }

        return await _payPalService
            .CreateSellerOnboardingAsync(
                user.Id,
                user.Email);
    }
}