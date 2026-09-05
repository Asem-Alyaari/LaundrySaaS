using LaundrySaaS.Drivers.Drivers;
using Microsoft.EntityFrameworkCore;
using Volo.Abp;
using Volo.Abp.EntityFrameworkCore.Modeling;

namespace LaundrySaaS.Drivers.EntityFrameworkCore;

public static class DriversDbContextModelCreatingExtensions
{
    public static void ConfigureDrivers(
        this ModelBuilder builder)
    {
        Check.NotNull(builder, nameof(builder));

        builder.Entity<Driver>(b =>
        {
            b.ToTable(DriversDbProperties.DbTablePrefix + "Drivers", DriversDbProperties.DbSchema);

            b.ConfigureByConvention();

            b.Property(d => d.FullName)
                .IsRequired()
                .HasMaxLength(128);

            b.Property(d => d.PhoneNumber)
                .IsRequired()
                .HasMaxLength(32);

            b.Property(d => d.VehicleInfo)
                .IsRequired()
                .HasMaxLength(256);

            b.Property(d => d.IsAvailable)
                .IsRequired();
        });
    }
}
