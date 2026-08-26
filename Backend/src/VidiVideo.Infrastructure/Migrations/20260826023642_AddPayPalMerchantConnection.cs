using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace VidiVideo.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddPayPalMerchantConnection : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "PayPalMerchantId",
                table: "Users",
                type: "nvarchar(64)",
                maxLength: 64,
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "PayPalMerchantId",
                table: "Users");
        }
    }
}
