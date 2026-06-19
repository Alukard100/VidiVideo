using VidiVideo.Application.Common;

namespace VidiVideo.Application.Countries;

public sealed record CreateCountryCommand(
    string Name, string Code) : ICommand<Guid>;
