using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using VidiVideo.Domain.Entities;

namespace VidiVideo.Infrastructure.Persistence.Configurations;

public sealed class ChannelEmojiConfiguration : IEntityTypeConfiguration<ChannelEmoji>
{
    public void Configure(EntityTypeBuilder<ChannelEmoji> builder)
    {
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Code).HasMaxLength(32).IsRequired();
        builder.Property(x => x.ImageUrl).HasMaxLength(1024).IsRequired();
        builder.HasOne(x => x.Creator).WithMany(x => x.ChannelEmojis).HasForeignKey(x => x.CreatorId).OnDelete(DeleteBehavior.Cascade);
        builder.HasIndex(x => new
        {
            x.CreatorId,
            x.Code
        })
        .IsUnique();
    }
}
