using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace LaundrySaaS.Migrations
{
    /// <inheritdoc />
    public partial class Add_Editions_Subscriptions_And_Service_Enhancements : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Description",
                table: "LaundriesServiceItems",
                type: "nvarchar(512)",
                maxLength: 512,
                nullable: true);

            migrationBuilder.AddColumn<double>(
                name: "DurationHours",
                table: "LaundriesServiceItems",
                type: "float",
                nullable: false,
                defaultValue: 0.0);

            migrationBuilder.AddColumn<string>(
                name: "Icon",
                table: "LaundriesServiceItems",
                type: "nvarchar(128)",
                maxLength: 128,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Unit",
                table: "LaundriesServiceItems",
                type: "nvarchar(32)",
                maxLength: 32,
                nullable: false,
                defaultValue: "piece");

            migrationBuilder.AddColumn<string>(
                name: "Color",
                table: "LaundriesServiceCategories",
                type: "nvarchar(32)",
                maxLength: 32,
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "DisplayOrder",
                table: "LaundriesServiceCategories",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<string>(
                name: "Icon",
                table: "LaundriesServiceCategories",
                type: "nvarchar(128)",
                maxLength: 128,
                nullable: true);

            migrationBuilder.CreateTable(
                name: "LaundrySaaSEditions",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    DisplayName = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                    Price = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: false),
                    AnnualPrice = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: false),
                    PlanType = table.Column<int>(type: "int", nullable: false),
                    IsFree = table.Column<bool>(type: "bit", nullable: false),
                    ExtraProperties = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    ConcurrencyStamp = table.Column<string>(type: "nvarchar(40)", maxLength: 40, nullable: false),
                    CreationTime = table.Column<DateTime>(type: "datetime2", nullable: false),
                    CreatorId = table.Column<Guid>(type: "uniqueidentifier", nullable: true),
                    LastModificationTime = table.Column<DateTime>(type: "datetime2", nullable: true),
                    LastModifierId = table.Column<Guid>(type: "uniqueidentifier", nullable: true),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false, defaultValue: false),
                    DeleterId = table.Column<Guid>(type: "uniqueidentifier", nullable: true),
                    DeletionTime = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_LaundrySaaSEditions", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "LaundrySaaSTenantSubscriptions",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    TenantId = table.Column<Guid>(type: "uniqueidentifier", nullable: true),
                    EditionId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    SubscriptionCycle = table.Column<int>(type: "int", nullable: false),
                    StartDate = table.Column<DateTime>(type: "datetime2", nullable: false),
                    ExpireDate = table.Column<DateTime>(type: "datetime2", nullable: false),
                    Status = table.Column<int>(type: "int", nullable: false),
                    ExtraProperties = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    ConcurrencyStamp = table.Column<string>(type: "nvarchar(40)", maxLength: 40, nullable: false),
                    CreationTime = table.Column<DateTime>(type: "datetime2", nullable: false),
                    CreatorId = table.Column<Guid>(type: "uniqueidentifier", nullable: true),
                    LastModificationTime = table.Column<DateTime>(type: "datetime2", nullable: true),
                    LastModifierId = table.Column<Guid>(type: "uniqueidentifier", nullable: true),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false, defaultValue: false),
                    DeleterId = table.Column<Guid>(type: "uniqueidentifier", nullable: true),
                    DeletionTime = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_LaundrySaaSTenantSubscriptions", x => x.Id);
                    table.ForeignKey(
                        name: "FK_LaundrySaaSTenantSubscriptions_LaundrySaaSEditions_EditionId",
                        column: x => x.EditionId,
                        principalTable: "LaundrySaaSEditions",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_LaundrySaaSTenantSubscriptions_EditionId",
                table: "LaundrySaaSTenantSubscriptions",
                column: "EditionId");

            migrationBuilder.CreateIndex(
                name: "IX_LaundrySaaSTenantSubscriptions_Status",
                table: "LaundrySaaSTenantSubscriptions",
                column: "Status");

            migrationBuilder.CreateIndex(
                name: "IX_LaundrySaaSTenantSubscriptions_TenantId",
                table: "LaundrySaaSTenantSubscriptions",
                column: "TenantId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "LaundrySaaSTenantSubscriptions");

            migrationBuilder.DropTable(
                name: "LaundrySaaSEditions");

            migrationBuilder.DropColumn(
                name: "Description",
                table: "LaundriesServiceItems");

            migrationBuilder.DropColumn(
                name: "DurationHours",
                table: "LaundriesServiceItems");

            migrationBuilder.DropColumn(
                name: "Icon",
                table: "LaundriesServiceItems");

            migrationBuilder.DropColumn(
                name: "Unit",
                table: "LaundriesServiceItems");

            migrationBuilder.DropColumn(
                name: "Color",
                table: "LaundriesServiceCategories");

            migrationBuilder.DropColumn(
                name: "DisplayOrder",
                table: "LaundriesServiceCategories");

            migrationBuilder.DropColumn(
                name: "Icon",
                table: "LaundriesServiceCategories");
        }
    }
}
