using VidiVideo.Application.Common;

public sealed record UpdateMyProfileCommand(
    string DisplayName,
    string? Bio,
    Guid? CountryId)
    : ICommand<Guid>;