using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;

namespace VidiVideo.Application.Countries
{
    public sealed class UpdateCountryCommandHandler : ICommandHandler<UpdateCountryCommand, CountryDto>
    {
        private readonly ICountryRepository _countryRepository;
        private readonly IUnitOfWork _unitOfWork;

        public UpdateCountryCommandHandler(ICountryRepository countryRepository, IUnitOfWork unitOfWork)
        {
            _countryRepository = countryRepository;
            _unitOfWork = unitOfWork;
        }
        public async Task<CountryDto> HandleAsync(UpdateCountryCommand command, CancellationToken cancellationToken)
        {
            if (string.IsNullOrWhiteSpace(command.Name) || string.IsNullOrWhiteSpace(command.Code) || command.Code.Length > 4)
                throw new ValidationException(
                    "Name and Code cannot be empty, Country code cannot have more than 4 characters");

            var name = command.Name.Trim();
            var code = command.Code.Trim().ToUpperInvariant();

            if (await _countryRepository.ExistsByCodeUpdateAsync(command.Id, code))
            {
                throw new ConflictException(
                    "Country with code already exists");
            }

            var country = await _countryRepository.GetByIdAsync(command.Id) ?? throw new NotFoundException("Country doesn't exist");

            country.Update(name, code);

            await _unitOfWork.SaveChangesAsync(cancellationToken);

            var result = new CountryDto(
                country.Id, country.Name, country.Code);

            return result;
        }
    }
}
