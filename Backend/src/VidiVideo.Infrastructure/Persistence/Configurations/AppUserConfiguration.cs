using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using VidiVideo.Domain.Entities;

namespace VidiVideo.Infrastructure.Persistence.Configurations;

public sealed class AppUserConfiguration : IEntityTypeConfiguration<AppUser>
{
    public void Configure(EntityTypeBuilder<AppUser> builder)
    {
        builder.HasKey(x => x.Id);
        builder.Property(x => x.UserName).HasMaxLength(64).IsRequired();
        builder.Property(x => x.Email).HasMaxLength(256).IsRequired();
        builder.Property(x => x.PasswordHash).HasMaxLength(512).IsRequired();
        builder.Property(x => x.DisplayName).HasMaxLength(100).IsRequired();
        builder.Property(x => x.Bio).HasMaxLength(500);
        builder.Property(x => x.AvatarUrl).HasMaxLength(1024);
        builder.HasOne(x => x.Country).WithMany(c => c.Users).HasForeignKey(x => x.CountryId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => x.Email).IsUnique();
        builder.HasIndex(x => x.UserName).IsUnique();
    }
}
