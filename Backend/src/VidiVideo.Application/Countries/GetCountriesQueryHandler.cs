using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;

namespace VidiVideo.Application.Countries;

public sealed class GetCountriesQueryHandler : IQueryHandler<GetCountriesQuery, PagedResult<CountryDto>>
{
    private readonly ICountryRepository _countryRepository;

    public GetCountriesQueryHandler(ICountryRepository countryRepository)
    {
        _countryRepository = countryRepository;
    }

    public async Task<PagedResult<CountryDto>> HandleAsync(GetCountriesQuery query, CancellationToken cancellationToken)
    {
        var countries = await _countryRepository.GetAllAsync(query.Page, query.PageSize, cancellationToken);

        var count = await _countryRepository.CountAsync(cancellationToken);

        var items = countries.Select(c => new CountryDto(c.Id, c.Name, c.Code)).ToList();

        return new PagedResult<CountryDto>(items, query.Page, query.PageSize, count);
    }
}
