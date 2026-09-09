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
            if (string.IsNullOrWhiteSpace(command.Name))
                throw new ValidationException("Country name is required");

            if (string.IsNullOrWhiteSpace(command.Code))
                throw new ValidationException("Country code is required");

            var name = command.Name.Trim();
            var code = command.Code.Trim().ToUpperInvariant();

            if (name.Length > 80)
                throw new ValidationException("Country name cannot exceed 80 characters");

            if (code.Length > 4)
                throw new ValidationException("Country code cannot exceed 4 characters");

            if (await _countryRepository.ExistsByCodeAsync(code))
            {
                throw new ConflictException(
                    "Country code already exists");
            }

            Country country = new(name, code);

            await _countryRepository.AddAsync(country);

            await _unitOfWork.SaveChangesAsync(cancellationToken);

            return country.Id;
        }
    }
}


