using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;
using VidiVideo.Domain.Entities;

namespace VidiVideo.Application.Countries
{
    public sealed class CreateCountryCommandHandler : ICommandHandler<CreateCountryCommand, Guid>
    {
        private readonly ICountryRepository _countryRepository;
        private readonly IUnitOfWork _unitOfWork;
        public CreateCountryCommandHandler(ICountryRepository countryRepository, IUnitOfWork unitOfWork)
        {
            _countryRepository = countryRepository;
            _unitOfWork = unitOfWork;
        }
        public async Task<Guid> HandleAsync(CreateCountryCommand command, CancellationToken cancellationToken)
        {
            if (string.IsNullOrWhiteSpace(command.Name) || string.IsNullOrWhiteSpace(command.Code) || command.Code.Length > 4)
                throw new ValidationException(
                    "Name and Code cannot be empty, Country code cannot have more than 4 characters");

            var code = command.Code.ToUpperInvariant();

            if (await _countryRepository.ExistsByCodeAsync(code))
            {
                throw new ConflictException(
                    "Country code already exists");
            }

            Country country = new(command.Name, command.Code);

            await _countryRepository.AddAsync(country);

            await _unitOfWork.SaveChangesAsync(cancellationToken);

            return country.Id;
        }
    }
}


