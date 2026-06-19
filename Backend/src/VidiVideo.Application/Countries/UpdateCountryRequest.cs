namespace VidiVideo.Application.Countries;

public sealed record UpdateCountryRequest(Guid Id, string Name, string Code);

