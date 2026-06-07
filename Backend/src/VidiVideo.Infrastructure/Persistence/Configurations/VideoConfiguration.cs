using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using VidiVideo.Domain.Entities;

namespace VidiVideo.Infrastructure.Persistence.Configurations;

public sealed class VideoConfiguration : IEntityTypeConfiguration<Video>
{
    public void Configure(EntityTypeBuilder<Video> builder)
    {
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Caption).HasMaxLength(500).IsRequired();
        builder.Property(x => x.VideoUrl).HasMaxLength(1024).IsRequired();
        builder.Property(x => x.ThumbnailUrl).HasMaxLength(1024).IsRequired();
        builder.HasOne(x => x.Creator)
            .WithMany(x => x.Videos)
            .HasForeignKey(x => x.CreatorId)
            .OnDelete(DeleteBehavior.Restrict);
        builder.HasOne(x => x.Category)
            .WithMany(x => x.Videos)
            .HasForeignKey(x => x.CategoryId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
