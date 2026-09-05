using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace LaundrySaaS.Migrations
{
    /// <inheritdoc />
    public partial class Added_Laundry_Location_Coordinates : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<double>(
                name: "Latitude",
                table: "LaundriesLaundries",
                type: "float(10)",
                precision: 10,
                scale: 7,
                nullable: true);

            migrationBuilder.AddColumn<double>(
                name: "Longitude",
                table: "LaundriesLaundries",
                type: "float(10)",
                precision: 10,
                scale: 7,
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Latitude",
                table: "LaundriesLaundries");

            migrationBuilder.DropColumn(
                name: "Longitude",
                table: "LaundriesLaundries");
        }
    }
}
