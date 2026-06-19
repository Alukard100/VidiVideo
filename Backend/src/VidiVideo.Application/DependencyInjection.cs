using Microsoft.Extensions.DependencyInjection;
using VidiVideo.Application.Common;
using VidiVideo.Application.Countries;
using VidiVideo.Application.Users;

namespace VidiVideo.Application;

public static class DependencyInjection
{
    public static IServiceCollection AddApplication(this IServiceCollection services)
    {
        //Commands
        services.AddScoped<ICommandHandler<RegisterUserCommand, Guid>, RegisterUserCommandHandler>();
        services.AddScoped<ICommandHandler<LoginUserCommand, LoginUserResponse>, LoginUserCommandHandler>();
        services.AddScoped<ICommandHandler<CreateCountryCommand, Guid>, CreateCountryCommandHandler>();
        services.AddScoped<ICommandHandler<UpdateCountryCommand, CountryDto>, UpdateCountryCommandHandler>();
        //Queries
        services.AddScoped<IQueryHandler<GetCountryByIdQuery, CountryDto>, GetCountryByIdQueryHandler>();
        services.AddScoped<IQueryHandler<GetCountriesQuery, List<CountryDto>>, GetCountriesQueryHandler>();
        //Delete Commands
        services.AddScoped<ICommandHandler<DeleteCountryCommand, bool>, DeleteCountryCommandHandler>();


        return services;
    }
}
