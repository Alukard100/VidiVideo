using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;

public sealed class UpdateMyProfileCommandHandler
    : ICommandHandler<UpdateMyProfileCommand, Guid>
{
    private readonly IUserRepository _userRepository;
    private readonly ICountryRepository _countryRepository;
    private readonly ICurrentUser _currentUser;
    private readonly IUnitOfWork _unitOfWork;

    public UpdateMyProfileCommandHandler(
        IUserRepository userRepository,
        ICountryRepository countryRepository,
        ICurrentUser currentUser,
        IUnitOfWork unitOfWork)
    {
        _userRepository = userRepository;
        _countryRepository = countryRepository;
        _currentUser = currentUser;
        _unitOfWork = unitOfWork;
    }

    public async Task<Guid> HandleAsync(
        UpdateMyProfileCommand command,
        CancellationToken cancellationToken)
    {
        var userId = _currentUser.UserId
            ?? throw new UnauthorizedException("Must be logged in.");

        var user = await _userRepository.GetByIdAsync(userId)
            ?? throw new NotFoundException("User doesn't exist.");

        if (string.IsNullOrWhiteSpace(command.DisplayName))
            throw new ValidationException("Display name is required.");


        if (command.CountryId.HasValue &&
            !await _countryRepository.ExistsByIdAsync(command.CountryId.Value))
        {
            throw new NotFoundException("Country doesn't exist.");
        }

        user.UpdateProfile(
            command.DisplayName,
            command.Bio,
            command.CountryId);

        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return user.Id;
    }
}