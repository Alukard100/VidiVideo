using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using VidiVideo.Domain.Entities;

namespace VidiVideo.Infrastructure.Persistence.Configurations;

public sealed class BusinessConfiguration :
    IEntityTypeConfiguration<CreatorSubscription>,
    IEntityTypeConfiguration<Payment>,
    IEntityTypeConfiguration<ContentReport>,
    IEntityTypeConfiguration<SearchHistory>,
    IEntityTypeConfiguration<VideoView>
{
    public void Configure(EntityTypeBuilder<CreatorSubscription> builder)
    {
        builder.HasKey(x => x.Id);
        builder.HasIndex(x => new { x.SubscriberId, x.CreatorId, x.EndsAtUtc });
        builder.HasOne(x => x.Subscriber).WithMany().HasForeignKey(x => x.SubscriberId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne(x => x.Creator).WithMany().HasForeignKey(x => x.CreatorId).OnDelete(DeleteBehavior.Restrict);
    }

    public void Configure(EntityTypeBuilder<Payment> builder)
    {
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Amount).HasPrecision(18, 2);
        builder.Property(x => x.Currency).HasMaxLength(3).IsRequired();
        builder.Property(x => x.Provider).HasMaxLength(40).IsRequired();
        builder.Property(x => x.ProviderPaymentId).HasMaxLength(256).IsRequired();
        builder.HasIndex(x => x.ProviderPaymentId).IsUnique();
    }

    public void Configure(EntityTypeBuilder<ContentReport> builder)
    {
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Reason).HasMaxLength(500).IsRequired();
        builder.Property(x => x.ResolutionNote).HasMaxLength(500);
        builder.HasOne(x => x.Reporter).WithMany().HasForeignKey(x => x.ReporterId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne(x => x.ReviewedBy).WithMany().HasForeignKey(x => x.ReviewedById).OnDelete(DeleteBehavior.Restrict);
    }

    public void Configure(EntityTypeBuilder<SearchHistory> builder)
    {
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Query).HasMaxLength(200).IsRequired();
    }

    public void Configure(EntityTypeBuilder<VideoView> builder)
    {
        builder.HasKey(x => x.Id);
        builder.Property(x => x.CompletionRate).HasPrecision(5, 2);
        builder.HasIndex(x => new { x.UserId, x.VideoId, x.CreatedAtUtc });
    }
}
