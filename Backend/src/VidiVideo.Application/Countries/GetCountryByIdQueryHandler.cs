using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;

namespace VidiVideo.Application.Countries;

public sealed class GetCountryByIdQueryHandler : IQueryHandler<GetCountryByIdQuery, CountryDto>
{
    private readonly ICountryRepository _countryRepository;

    public GetCountryByIdQueryHandler(ICountryRepository countryRepository)
    {
        _countryRepository = countryRepository;
    }

    public async Task<CountryDto> HandleAsync(GetCountryByIdQuery query, CancellationToken cancellationToken)
    {
        var country = await _countryRepository.GetByIdAsync(query.Id) ?? throw new NotFoundException("Country doesn't exist");

        return new CountryDto(
            country.Id,
            country.Name,
            country.Code);
    }
}
