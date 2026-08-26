using Microsoft.Extensions.DependencyInjection;
using VidiVideo.Application.Categories;
using VidiVideo.Application.Common;
using VidiVideo.Application.ContentReports;
using VidiVideo.Application.Countries;
using VidiVideo.Application.Dashboard;
using VidiVideo.Application.Followers;
using VidiVideo.Application.Hashtags;
using VidiVideo.Application.Notifications;
using VidiVideo.Application.Payments.PayPal;
using VidiVideo.Application.Payments.Refunds;
using VidiVideo.Application.Recommendations;
using VidiVideo.Application.Reports.RevenueReport;
using VidiVideo.Application.Reports.VideosReport;
using VidiVideo.Application.SearchHistories;
using VidiVideo.Application.Users;
using VidiVideo.Application.Users.Activities;
using VidiVideo.Application.Users.Administrative;
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
        services.AddScoped<ICommandHandler<ChangePasswordCommand, bool>, ChangePasswordCommandHandler>();
        services.AddScoped<ICommandHandler<CreateCountryCommand, Guid>, CreateCountryCommandHandler>();
        services.AddScoped<ICommandHandler<UpdateCountryCommand, CountryDto>, UpdateCountryCommandHandler>();
        services.AddScoped<ICommandHandler<CreateHashtagCommand, Guid>, CreateHashtagCommandHandler>();
        services.AddScoped<ICommandHandler<UploadVideoCommand, string>, UploadVideoCommandHandler>();
        services.AddScoped<ICommandHandler<CreateVideoCommand, Guid>, CreateVideoCommandHandler>();
        services.AddScoped<ICommandHandler<CreateThumbnailCommand, string>, CreateThumbnailCommandHandler>();
        services.AddScoped<ICommandHandler<CreateCategoryCommand, Guid>, CreateCategoryCommandHandler>();
        services.AddScoped<ICommandHandler<UpdateCategoryCommand, CategoryDTO>, UpdateCategoryCommandHandler>();
        services.AddScoped<ICommandHandler<UpdateVideoCommand, Guid>, UpdateVideoCommandHandler>();
        services.AddScoped<ICommandHandler<LikeVideoCommand, LikeDto>, LikeVideoCommandHandler>();
        services.AddScoped<ICommandHandler<CreateCommentCommand, Guid>, CreateCommentCommandHandler>();
        services.AddScoped<ICommandHandler<UpdateCommentCommand, Guid>, UpdateCommentCommandHandler>();
        services.AddScoped<ICommandHandler<FollowCommand, bool>, FollowCommandHandler>();
        services.AddScoped<ICommandHandler<UnfollowCommand, bool>, UnfollowCommandHandler>();
        services.AddScoped<ICommandHandler<RecordVideoViewCommand, Guid>, RecordVideoViewCommandHandler>();
        services.AddScoped<ICommandHandler<MarkNotificationAsReadCommand, bool>, MarkNotificationAsReadCommandHandler>();
        services.AddScoped<ICommandHandler<MarkAllNotificationsAsReadCommand, bool>, MarkAllNotificationsAsReadCommandHandler>();
        services.AddScoped<ICommandHandler<CreateSearchHistoryCommand, Guid>, CreateSearchHistoryCommandHandler>();
        services.AddScoped<ICommandHandler<CreatePayPalOrderCommand, PayPalOrderDto>, CreatePayPalOrderCommandHandler>();
        services.AddScoped<ICommandHandler<CapturePayPalOrderCommand, bool>, CapturePayPalOrderCommandHandler>();
        services.AddScoped<ICommandHandler<CreateContentReportCommand, Guid>, CreateContentReportCommandHandler>();
        services.AddScoped<ICommandHandler<ReviewContentReportCommand, bool>, ReviewContentReportCommandHandler>();
        services.AddScoped<ICommandHandler<UpdateMyProfileCommand, Guid>, UpdateMyProfileCommandHandler>();
        services.AddScoped<ICommandHandler<UploadAvatarCommand, string>, UploadAvatarCommandHandler>();
        services.AddScoped<ICommandHandler<UpdateUserStatusCommand, bool>, UpdateUserStatusCommandHandler>();
        services.AddScoped<ICommandHandler<CreateStaffCommand, Guid>, CreateStaffCommandHandler>();
        services.AddScoped<ICommandHandler<UpdateStaffRoleCommand, bool>, UpdateStaffRoleCommandHandler>();
        services.AddScoped<ICommandHandler<RefundPaymentCommand, bool>, RefundPaymentCommandHandler>();
        services.AddScoped<ICommandHandler<CreateRefundRequestCommand, Guid>, CreateRefundRequestCommandHandler>();
        services.AddScoped<ICommandHandler<ApproveRefundRequestCommand, bool>, ApproveRefundRequestCommandHandler>();
        services.AddScoped<ICommandHandler<RejectRefundRequestCommand, bool>, RejectRefundRequestCommandHandler>();
        services.AddScoped<ICommandHandler<CreatePayPalOnboardingCommand, PayPalOnboardingResult>, CreatePayPalOnboardingCommandHandler>();
        services.AddScoped<ICommandHandler<CompletePayPalOnboardingCommand, bool>, CompletePayPalOnboardingCommandHandler>();
        //Queries
        services.AddScoped<IQueryHandler<GetCountryByIdQuery, CountryDto>, GetCountryByIdQueryHandler>();
        services.AddScoped<IQueryHandler<GetCountriesQuery, PagedResult<CountryDto>>, GetCountriesQueryHandler>();
        services.AddScoped<IQueryHandler<GetHashtagByIdQuery, HashtagDto>, GetHashtagByIdQueryHandler>();
        services.AddScoped<IQueryHandler<GetHashtagsQuery, PagedResult<HashtagDto>>, GetHashtagsQueryHandler>();
        services.AddScoped<IQueryHandler<GetCategoryByIdQuery, CategoryDTO>, GetCategoryByIdQueryHandler>();
        services.AddScoped<IQueryHandler<GetCategoriesQuery, PagedResult<CategoryDTO>>, GetCategoriesQueryHandler>();
        services.AddScoped<IQueryHandler<GetVideosQuery, PagedResult<VideoSummaryDto>>, GetVideosQueryHandler>();
        services.AddScoped<IQueryHandler<GetVideoByIdQuery, VideoDto>, GetVideoByIdQueryHandler>();
        services.AddScoped<IQueryHandler<GetVideoCommentsQuery, PagedResult<CommentDto>>, GetVideoCommentsQueryHandler>();
        services.AddScoped<IQueryHandler<FollowersQuery, PagedResult<UserFollowDto>>, FollowersQueryHandler>();
        services.AddScoped<IQueryHandler<FollowingQuery, PagedResult<UserFollowDto>>, FollowingQueryHandler>();
        services.AddScoped<IQueryHandler<GetNotificationsQuery, PagedResult<NotificationMessage>>, GetNotificationsQueryHandler>();
        services.AddScoped<IQueryHandler<GetSearchHistoryQuery, PagedResult<SearchHistoryDto>>, GetSearchHistoryQueryHandler>();
        services.AddScoped<IQueryHandler<GenerateVideosReportQuery, byte[]>, GenerateVideosReportQueryHandler>();
        services.AddScoped<IQueryHandler<GenerateRevenueReportQuery, byte[]>, GenerateRevenueReportQueryHandler>();
        services.AddScoped<IQueryHandler<GetUserProfileQuery, UserProfileDto>, GetUserProfileQueryHandler>();
        services.AddScoped<IQueryHandler<GetMyProfileQuery, CurrentUserProfileDto>, GetMyProfileQueryHandler>();
        services.AddScoped<IQueryHandler<GetRecommendedVideosQuery, PagedResult<VideoFeedDto>>, GetRecommendedVideosQueryHandler>();
        services.AddScoped<IQueryHandler<GetFollowingFeedQuery, PagedResult<VideoFeedDto>>, GetFollowingFeedQueryHandler>();
        services.AddScoped<IQueryHandler<GetVideoStreamQuery, VideoStreamResult>, GetVideoStreamQueryHandler>();
        services.AddScoped<IQueryHandler<GetUsersQuery, PagedResult<UserSummaryDto>>, GetUsersQueryHandler>();
        services.AddScoped<IQueryHandler<GetContentReportsQuery, PagedResult<ContentReportSummaryDto>>, GetContentReportsQueryHandler>();
        services.AddScoped<IQueryHandler<GetContentReportDetailQuery, ContentReportDetailDto>, GetContentReportDetailQueryHandler>();
        services.AddScoped<IQueryHandler<GetContentReportStatsQuery, ContentReportStatsDto>, GetContentReportStatsQueryHandler>();
        services.AddScoped<IQueryHandler<GetModerationVideoStreamQuery, VideoStreamResult>, GetModerationVideoStreamQueryHandler>();
        services.AddScoped<IQueryHandler<GetReportsByStatusQuery, PagedResult<ContentReportDto>>, GetReportsByStatusQueryHandler>();
        services.AddScoped<IQueryHandler<GetStaffQuery, PagedResult<StaffSummaryDto>>, GetStaffQueryHandler>();
        services.AddScoped<IQueryHandler<GetDashboardOverviewQuery, DashboardOverviewDto>, GetDashboardOverviewQueryHandler>();
        services.AddScoped<IQueryHandler<GetAllRefundRequestsQuery, PagedResult<RefundRequestDto>>, GetAllRefundRequestsQueryHandler>();
        //Delete Commands
        services.AddScoped<ICommandHandler<DeleteCountryCommand, bool>, DeleteCountryCommandHandler>();
        services.AddScoped<ICommandHandler<DeleteHashtagCommand, bool>, DeleteHashtagCommandHandler>();
        services.AddScoped<ICommandHandler<DeleteCategoryCommand, bool>, DeleteCategoryCommandHandler>();
        services.AddScoped<ICommandHandler<DeleteVideoCommand, bool>, DeleteVideoCommandHandler>();
        services.AddScoped<ICommandHandler<UnlikeVideoCommand, bool>, UnlikeVideoCommandHandler>();
        services.AddScoped<ICommandHandler<DeleteCommentCommand, bool>, DeleteCommentCommandHandler>();
        services.AddScoped<ICommandHandler<DeleteSearchHistoryCommand, bool>, DeleteSearchHistoryCommandHandler>();
        services.AddScoped<ICommandHandler<ClearSearchHistoryCommand, bool>, ClearSearchHistoryCommandHandler>();
        services.AddScoped<ICommandHandler<RemoveReportedContentCommand, bool>, RemoveReportedContentCommandHandler>();
        services.AddScoped<ICommandHandler<DeleteStaffCommand, bool>, DeleteStaffCommandHandler>();

        return services;
    }
}
