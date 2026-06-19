namespace VidiVideo.Application.Countries;

public sealed record CountryDto(
    Guid Id,
    string Name,
    string Code);