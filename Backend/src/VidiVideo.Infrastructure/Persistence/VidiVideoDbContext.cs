using Microsoft.EntityFrameworkCore;
using VidiVideo.Domain.Entities;

namespace VidiVideo.Infrastructure.Persistence;

public sealed class VidiVideoDbContext(DbContextOptions<VidiVideoDbContext> options) : DbContext(options)
{
    public DbSet<AppUser> Users => Set<AppUser>();
    public DbSet<Video> Videos => Set<Video>();
    public DbSet<Category> Categories => Set<Category>();
    public DbSet<Hashtag> Hashtags => Set<Hashtag>();
    public DbSet<VideoHashtag> VideoHashtags => Set<VideoHashtag>();
    public DbSet<Comment> Comments => Set<Comment>();
    public DbSet<Like> Likes => Set<Like>();
    public DbSet<Follow> Follows => Set<Follow>();
    public DbSet<CreatorSubscription> CreatorSubscriptions => Set<CreatorSubscription>();
    public DbSet<Payment> Payments => Set<Payment>();
    public DbSet<ContentReport> ContentReports => Set<ContentReport>();
    public DbSet<SearchHistory> SearchHistories => Set<SearchHistory>();
    public DbSet<VideoView> VideoViews => Set<VideoView>();
    public DbSet<Notification> Notifications => Set<Notification>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(VidiVideoDbContext).Assembly);
    }
}
