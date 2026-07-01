using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using VidiVideo.Api.Configuration;
using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Infrastructure.Authentication;
using VidiVideo.Infrastructure.Media;
using VidiVideo.Infrastructure.Messaging;
using VidiVideo.Infrastructure.Persistence;
using VidiVideo.Infrastructure.Persistence.Repositories;
using VidiVideo.Infrastructure.Persistence.Seed;

namespace VidiVideo.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        var connectionString = configuration.GetConnectionString("DefaultConnection")
            ?? throw new InvalidOperationException("DefaultConnection is not configured.");

        services.AddDbContext<VidiVideoDbContext>(options => options.UseSqlServer(connectionString));
        services.Configure<RabbitMqOptions>(configuration.GetSection("RabbitMq"));
        services.Configure<JwtOptions>(configuration.GetSection("Jwt"));

        services.AddScoped<IMessagePublisher, RabbitMqMessagePublisher>();
        services.AddScoped<IPasswordHasher, BCryptPasswordHasher>();
        services.AddScoped<ITokenGenerator, JwtTokenGenerator>();
        services.AddScoped<IUnitOfWork, UnitOfWork>();
        services.AddScoped<IUserRepository, UserRepository>();
        services.AddScoped<ICountryRepository, CountryRepository>();
        services.AddScoped<IHashtagRepository, HashtagRepository>();
        services.AddScoped<IVideoStorageService, VideoStorageService>();
        services.AddScoped<IImageStorageService, ImageStorageService>();
        services.AddScoped<IVideoRepository, VideoRepository>();
        services.AddScoped<ICategoryRepository, CategoryRepository>();
        services.AddScoped<IVideoRepository, VideoRepository>();

        services.AddScoped<DatabaseSeeder>();


        return services;
    }
}
