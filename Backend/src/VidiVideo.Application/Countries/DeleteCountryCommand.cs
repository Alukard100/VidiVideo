using VidiVideo.Application.Common;

namespace VidiVideo.Application.Countries;

public sealed record DeleteCountryCommand(Guid Id) : ICommand<bool>;
