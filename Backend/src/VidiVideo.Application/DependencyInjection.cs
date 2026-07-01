using Microsoft.Extensions.DependencyInjection;
using VidiVideo.Application.Categories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Countries;
using VidiVideo.Application.Hashtags;
using VidiVideo.Application.Users;
using VidiVideo.Application.Videos;
using VidiVideo.Application.Videos.Thumbnails;
using VidiVideo.Application.Videos.VideoFile;

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
        services.AddScoped<ICommandHandler<CreateHashtagCommand, Guid>, CreateHashtagCommandHandler>();
        services.AddScoped<ICommandHandler<UploadVideoCommand, string>, UploadVideoCommandHandler>();
        services.AddScoped<ICommandHandler<CreateVideoCommand, Guid>, CreateVideoCommandHandler>();
        services.AddScoped<ICommandHandler<CreateThumbnailCommand, string>, CreateThumbnailCommandHandler>();
        services.AddScoped<ICommandHandler<CreateCategoryCommand, Guid>, CreateCategoryCommandHandler>();
        services.AddScoped<ICommandHandler<UpdateCategoryCommand, CategoryDTO>, UpdateCategoryCommandHandler>();
        services.AddScoped<ICommandHandler<CreateHashtagCommand, Guid>, CreateHashtagCommandHandler>();
        //Queries
        services.AddScoped<IQueryHandler<GetCountryByIdQuery, CountryDto>, GetCountryByIdQueryHandler>();
        services.AddScoped<IQueryHandler<GetCountriesQuery, List<CountryDto>>, GetCountriesQueryHandler>();
        services.AddScoped<IQueryHandler<GetHashtagByIdQuery, HashtagDto>, GetHashtagByIdQueryHandler>();
        services.AddScoped<IQueryHandler<GetHashtagsQuery, List<HashtagDto>>, GetHashtagsQueryHandler>();
        services.AddScoped<IQueryHandler<GetCategoryByIdQuery, CategoryDTO>, GetCategoryByIdQueryHandler>();
        services.AddScoped<IQueryHandler<GetCategoriesQuery, List<CategoryDTO>>, GetCategoriesQueryHandler>();
        services.AddScoped<IQueryHandler<GetHashtagByIdQuery, HashtagDto>, GetHashtagByIdQueryHandler>();
        services.AddScoped<IQueryHandler<GetHashtagsQuery, List<HashtagDto>>, GetHashtagsQueryHandler>();
        //Delete Commands
        services.AddScoped<ICommandHandler<DeleteCountryCommand, bool>, DeleteCountryCommandHandler>();
        services.AddScoped<ICommandHandler<DeleteHashtagCommand, bool>, DeleteHashtagCommandHandler>();
        services.AddScoped<ICommandHandler<DeleteCategoryCommand, bool>, DeleteCategoryCommandHandler>();
        services.AddScoped<ICommandHandler<DeleteHashtagCommand, bool>, DeleteHashtagCommandHandler>();


        return services;
    }
}
