using LaundrySaaS.Laundries.Categories;
using LaundrySaaS.Laundries.Items;
using LaundrySaaS.Laundries.Laundries;
using Microsoft.EntityFrameworkCore;
using Volo.Abp;
using Volo.Abp.EntityFrameworkCore.Modeling;

namespace LaundrySaaS.Laundries.EntityFrameworkCore;

public static class LaundriesDbContextModelCreatingExtensions
{
    public static void ConfigureLaundries(
        this ModelBuilder builder)
    {
        Check.NotNull(builder, nameof(builder));

        builder.Entity<Laundry>(b =>
        {
            b.ToTable(LaundriesDbProperties.DbTablePrefix + "Laundries", LaundriesDbProperties.DbSchema);

            b.ConfigureByConvention();

            b.Property(l => l.Name)
                .IsRequired()
                .HasMaxLength(128);

            b.Property(l => l.PhoneNumber)
                .IsRequired()
                .HasMaxLength(32);

            b.Property(l => l.IsActive)
                .IsRequired();

            b.Property(l => l.Latitude)
                .HasPrecision(10, 7);

            b.Property(l => l.Longitude)
                .HasPrecision(10, 7);

            b.OwnsOne(l => l.Address, addr =>
            {
                addr.Property(a => a.City).IsRequired().HasMaxLength(64).HasColumnName("Address_City");
                addr.Property(a => a.District).IsRequired().HasMaxLength(64).HasColumnName("Address_District");
                addr.Property(a => a.Street).IsRequired().HasMaxLength(128).HasColumnName("Address_Street");
                addr.Property(a => a.BuildingNumber).IsRequired().HasMaxLength(16).HasColumnName("Address_BuildingNumber");
            });
        });

        builder.Entity<ServiceCategory>(b =>
        {
            b.ToTable(LaundriesDbProperties.DbTablePrefix + "ServiceCategories", LaundriesDbProperties.DbSchema);

            b.ConfigureByConvention();

            b.Property(c => c.Name)
                .IsRequired()
                .HasMaxLength(128);

            b.Property(c => c.LaundryId)
                .IsRequired();

            b.Property(c => c.Icon)
                .HasMaxLength(128);

            b.Property(c => c.Color)
                .HasMaxLength(32);

            b.Property(c => c.DisplayOrder)
                .IsRequired()
                .HasDefaultValue(0);
        });

        builder.Entity<ServiceItem>(b =>
        {
            b.ToTable(LaundriesDbProperties.DbTablePrefix + "ServiceItems", LaundriesDbProperties.DbSchema);

            b.ConfigureByConvention();

            b.Property(i => i.Name)
                .IsRequired()
                .HasMaxLength(128);

            b.Property(i => i.Price)
                .IsRequired()
                .HasPrecision(18, 2);

            b.Property(i => i.CategoryId)
                .IsRequired();

            b.Property(i => i.LaundryId)
                .IsRequired();

            b.Property(i => i.IsActive)
                .IsRequired();

            b.Property(i => i.Unit)
                .IsRequired()
                .HasMaxLength(32)
                .HasDefaultValue("piece");

            b.Property(i => i.DurationHours)
                .IsRequired()
                .HasDefaultValue(0);

            b.Property(i => i.Description)
                .HasMaxLength(512);

            b.Property(i => i.Icon)
                .HasMaxLength(128);
        });
    }
}
