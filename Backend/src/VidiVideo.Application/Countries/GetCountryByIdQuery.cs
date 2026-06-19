using VidiVideo.Application.Common;

namespace VidiVideo.Application.Countries;

public sealed record GetCountryByIdQuery(Guid Id) : IQuery<CountryDto>;