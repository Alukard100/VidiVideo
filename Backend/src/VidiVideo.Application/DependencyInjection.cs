using Microsoft.Extensions.DependencyInjection;
using VidiVideo.Application.Common;
using VidiVideo.Application.Users;

namespace VidiVideo.Application;

public static class DependencyInjection
{
    public static IServiceCollection AddApplication(this IServiceCollection services)
    {

        services.AddScoped<ICommandHandler<RegisterUserCommand, Guid>, RegisterUserCommandHandler>();
        services.AddScoped<ICommandHandler<LoginUserCommand, LoginUserResponse>, LoginUserCommandHandler>();

        return services;
    }
}
