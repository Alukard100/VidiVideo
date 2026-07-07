using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using VidiVideo.Domain.Entities;

namespace VidiVideo.Infrastructure.Persistence.Configurations;

public sealed class SocialConfiguration :
    IEntityTypeConfiguration<Category>,
    IEntityTypeConfiguration<Hashtag>,
    IEntityTypeConfiguration<VideoHashtag>,
    IEntityTypeConfiguration<Comment>,
    IEntityTypeConfiguration<Like>,
    IEntityTypeConfiguration<Follow>
{
    public void Configure(EntityTypeBuilder<Category> builder)
    {
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Name).HasMaxLength(80).IsRequired();
        builder.HasIndex(x => x.Name).IsUnique();
    }

    public void Configure(EntityTypeBuilder<Hashtag> builder)
    {
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Name).HasMaxLength(80).IsRequired();
        builder.HasIndex(x => x.Name).IsUnique();
    }

    public void Configure(EntityTypeBuilder<VideoHashtag> builder)
    {
        builder.HasKey(x => new { x.VideoId, x.HashtagId });

        builder.HasOne(x => x.Video)
            .WithMany(x => x.VideoHashtags)
            .HasForeignKey(x => x.VideoId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(x => x.Hashtag)
            .WithMany(x => x.VideoHashtags)
            .HasForeignKey(x => x.HashtagId)
            .OnDelete(DeleteBehavior.Cascade);
    }

    public void Configure(EntityTypeBuilder<Comment> builder)
    {
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Body).HasMaxLength(500).IsRequired();
        builder.HasOne(x => x.Author).WithMany().HasForeignKey(x => x.AuthorId).OnDelete(DeleteBehavior.Restrict);
    }

    public void Configure(EntityTypeBuilder<Like> builder)
    {
        builder.HasKey(x => x.Id);
        builder.HasIndex(x => new { x.VideoId, x.UserId }).IsUnique();
        builder.HasOne(x => x.User).WithMany().HasForeignKey(x => x.UserId).OnDelete(DeleteBehavior.Restrict);
    }

    public void Configure(EntityTypeBuilder<Follow> builder)
    {
        builder.HasKey(x => x.Id);
        builder.HasIndex(x => new { x.FollowerId, x.CreatorId }).IsUnique();
        builder.HasOne(x => x.Follower).WithMany(x => x.Following).HasForeignKey(x => x.FollowerId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne(x => x.Creator).WithMany(x => x.Followers).HasForeignKey(x => x.CreatorId).OnDelete(DeleteBehavior.Restrict);
    }

    public void Configure(EntityTypeBuilder<Notification> builder)
    {
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Title).HasMaxLength(80).IsRequired();
        builder.Property(x => x.Content).HasMaxLength(500).IsRequired();
        builder.HasOne(x => x.User).WithMany().HasForeignKey(x => x.UserId).OnDelete(DeleteBehavior.Cascade);
        builder.HasIndex(x => new { x.UserId, x.IsRead });
    }

    public void Configure(EntityTypeBuilder<Country> builder)
    {
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Name).HasMaxLength(80).IsRequired();
        builder.Property(x => x.Code).HasMaxLength(4).IsRequired();
        builder.HasIndex(x => new { x.Name, x.Code }).IsUnique();
    }
}
