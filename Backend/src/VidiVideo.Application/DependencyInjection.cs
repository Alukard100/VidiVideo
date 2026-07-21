using Microsoft.Extensions.DependencyInjection;
using VidiVideo.Application.Categories;
using VidiVideo.Application.Common;
using VidiVideo.Application.ContentReports;
using VidiVideo.Application.Countries;
using VidiVideo.Application.Followers;
using VidiVideo.Application.Hashtags;
using VidiVideo.Application.Notifications;
using VidiVideo.Application.Payments.PayPal;
using VidiVideo.Application.Reports.RevenueReport;
using VidiVideo.Application.Reports.VideosReport;
using VidiVideo.Application.SearchHistories;
using VidiVideo.Application.Users;
using VidiVideo.Application.Videos;
using VidiVideo.Application.Videos.Comments;
using VidiVideo.Application.Videos.Likes;
using VidiVideo.Application.Videos.Thumbnails;
using VidiVideo.Application.Videos.VideoFile;
using VidiVideo.Application.VideoViews;

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
        services.AddScoped<ICommandHandler<UpdateVideoCommand, Guid>, UpdateVideoCommandHandler>();
        services.AddScoped<ICommandHandler<LikeVideoCommand, LikeDto>, LikeVideoCommandHandler>();
        services.AddScoped<ICommandHandler<CreateCommentCommand, Guid>, CreateCommentCommandHandler>();
        services.AddScoped<ICommandHandler<UpdateCommentCommand, Guid>, UpdateCommentCommandHandler>();
        services.AddScoped<ICommandHandler<FollowCommand, bool>, FollowCommandHandler>();
        services.AddScoped<ICommandHandler<UnfollowCommand, bool>, UnfollowCommandHandler>();
        services.AddScoped<ICommandHandler<RecordVideoViewCommand, Guid>, RecordVideoViewCommandHandler>();
        services.AddScoped<ICommandHandler<MarkNotificationAsReadCommand, bool>, MarkNotificationAsReadCommandHandler>();
        services.AddScoped<ICommandHandler<CreateSearchHistoryCommand, Guid>, CreateSearchHistoryCommandHandler>();
        services.AddScoped<ICommandHandler<CreatePayPalOrderCommand, string>, CreatePayPalOrderCommandHandler>();
        services.AddScoped<ICommandHandler<CapturePayPalOrderCommand, bool>, CapturePayPalOrderCommandHandler>();
        services.AddScoped<ICommandHandler<CreateContentReportCommand, Guid>, CreateContentReportCommandHandler>();
        services.AddScoped<ICommandHandler<ReviewContentReportCommand, Guid>, ReviewContentReportCommandHandler>();
        //Queries
        services.AddScoped<IQueryHandler<GetCountryByIdQuery, CountryDto>, GetCountryByIdQueryHandler>();
        services.AddScoped<IQueryHandler<GetCountriesQuery, List<CountryDto>>, GetCountriesQueryHandler>();
        services.AddScoped<IQueryHandler<GetHashtagByIdQuery, HashtagDto>, GetHashtagByIdQueryHandler>();
        services.AddScoped<IQueryHandler<GetHashtagsQuery, List<HashtagDto>>, GetHashtagsQueryHandler>();
        services.AddScoped<IQueryHandler<GetCategoryByIdQuery, CategoryDTO>, GetCategoryByIdQueryHandler>();
        services.AddScoped<IQueryHandler<GetCategoriesQuery, List<CategoryDTO>>, GetCategoriesQueryHandler>();
        services.AddScoped<IQueryHandler<GetHashtagByIdQuery, HashtagDto>, GetHashtagByIdQueryHandler>();
        services.AddScoped<IQueryHandler<GetHashtagsQuery, List<HashtagDto>>, GetHashtagsQueryHandler>();
        services.AddScoped<IQueryHandler<GetVideosQuery, PagedResult<VideoSummaryDto>>, GetVideosQueryHandler>();
        services.AddScoped<IQueryHandler<GetVideoByIdQuery, VideoDto>, GetVideoByIdQueryHandler>();
        services.AddScoped<IQueryHandler<GetVideoCommentsQuery, PagedResult<CommentDto>>, GetVideoCommentsQueryHandler>();
        services.AddScoped<IQueryHandler<FollowersQuery, PagedResult<UserFollowDto>>, FollowersQueryHandler>();
        services.AddScoped<IQueryHandler<FollowingQuery, PagedResult<UserFollowDto>>, FollowingQueryHandler>();
        services.AddScoped<IQueryHandler<GetNotificationsQuery, PagedResult<NotificationMessage>>, GetNotificationsQueryHandler>();
        services.AddScoped<IQueryHandler<GetSearchHistoryQuery, PagedResult<SearchHistoryDto>>, GetSearchHistoryQueryHandler>();
        services.AddScoped<IQueryHandler<GetContentReportsQuery, PagedResult<ContentReportDto>>, GetContentReportsQueryHandler>();
        services.AddScoped<IQueryHandler<GenerateVideosReportQuery, byte[]>, GenerateVideosReportQueryHandler>();
        services.AddScoped<IQueryHandler<GenerateRevenueReportQuery, byte[]>, GenerateRevenueReportQueryHandler>();
        //Delete Commands
        services.AddScoped<ICommandHandler<DeleteCountryCommand, bool>, DeleteCountryCommandHandler>();
        services.AddScoped<ICommandHandler<DeleteHashtagCommand, bool>, DeleteHashtagCommandHandler>();
        services.AddScoped<ICommandHandler<DeleteCategoryCommand, bool>, DeleteCategoryCommandHandler>();
        services.AddScoped<ICommandHandler<DeleteHashtagCommand, bool>, DeleteHashtagCommandHandler>();
        services.AddScoped<ICommandHandler<DeleteVideoCommand, bool>, DeleteVideoCommandHandler>();
        services.AddScoped<ICommandHandler<UnlikeVideoCommand, bool>, UnlikeVideoCommandHandler>();
        services.AddScoped<ICommandHandler<DeleteCommentCommand, bool>, DeleteCommentCommandHandler>();
        services.AddScoped<ICommandHandler<DeleteSearchHistoryCommand, bool>, DeleteSearchHistoryCommandHandler>();
        services.AddScoped<ICommandHandler<ClearSearchHistoryCommand, bool>, ClearSearchHistoryCommandHandler>();

        return services;
    }
}
