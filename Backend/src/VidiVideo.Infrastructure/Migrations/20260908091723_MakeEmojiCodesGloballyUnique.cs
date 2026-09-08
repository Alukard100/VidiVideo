using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace VidiVideo.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class MakeEmojiCodesGloballyUnique : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_ChannelEmojis_Code",
                table: "ChannelEmojis");

            migrationBuilder.CreateIndex(
                name: "IX_ChannelEmojis_Code",
                table: "ChannelEmojis",
                column: "Code",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_ChannelEmojis_Code",
                table: "ChannelEmojis");

            migrationBuilder.CreateIndex(
                name: "IX_ChannelEmojis_Code",
                table: "ChannelEmojis",
                column: "Code",
                unique: true,
                filter: "[IsDeleted] = 0");
        }
    }
}
