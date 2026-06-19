using VidiVideo.Application.Common;

namespace VidiVideo.Application.Countries;

public sealed record UpdateCountryCommand(Guid Id, string Name, string Code) : ICommand<CountryDto>;
