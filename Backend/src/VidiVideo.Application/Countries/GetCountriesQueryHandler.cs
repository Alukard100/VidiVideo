using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;

namespace VidiVideo.Application.Countries;

public sealed class GetCountriesQueryHandler : IQueryHandler<GetCountriesQuery, List<CountryDto>>
{
    private readonly ICountryRepository _countryRepository;

    public GetCountriesQueryHandler(ICountryRepository countryRepository)
    {
        _countryRepository = countryRepository;
    }

    public async Task<List<CountryDto>> HandleAsync(GetCountriesQuery query, CancellationToken cancellationToken)
    {
        var countries = await _countryRepository.GetAllAsync();

        return countries
            .Select(c => new CountryDto(
                c.Id, c.Name, c.Code))
            .ToList();
    }
}
