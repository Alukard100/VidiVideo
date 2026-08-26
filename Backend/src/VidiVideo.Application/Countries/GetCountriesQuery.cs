using VidiVideo.Application.Common;

namespace VidiVideo.Application.Countries;

public sealed record GetCountriesQuery() : PagedRequest, IQuery<PagedResult<CountryDto>>;
