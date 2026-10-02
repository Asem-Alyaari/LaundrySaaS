using LaundrySaaS.Customers.Customers;
using Microsoft.EntityFrameworkCore;
using Volo.Abp;
using Volo.Abp.EntityFrameworkCore.Modeling;

namespace LaundrySaaS.Customers.EntityFrameworkCore;

public static class CustomersDbContextModelCreatingExtensions
{
    public static void ConfigureCustomers(
        this ModelBuilder builder)
    {
        Check.NotNull(builder, nameof(builder));

        builder.Entity<Customer>(b =>
        {
            b.ToTable(CustomersDbProperties.DbTablePrefix + "Customers", CustomersDbProperties.DbSchema);

            b.ConfigureByConvention();

            b.Property(c => c.FullName)
                .IsRequired()
                .HasMaxLength(128);

            b.Property(c => c.PhoneNumber)
                .IsRequired()
                .HasMaxLength(32);

            // Map Address ValueObject as owned entity (columns inline in Customer table)
            b.OwnsOne(c => c.Address, addr =>
            {
                addr.Property(a => a.City).IsRequired().HasMaxLength(64).HasColumnName("Address_City");
                addr.Property(a => a.District).IsRequired().HasMaxLength(64).HasColumnName("Address_District");
                addr.Property(a => a.Street).IsRequired().HasMaxLength(128).HasColumnName("Address_Street");
                addr.Property(a => a.BuildingNumber).IsRequired().HasMaxLength(16).HasColumnName("Address_BuildingNumber");
            });
        });

        builder.Entity<CustomerAddress>(b =>
        {
            b.ToTable(CustomersDbProperties.DbTablePrefix + "CustomerAddresses", CustomersDbProperties.DbSchema);
            b.ConfigureByConvention();
            b.Property(a => a.Title).IsRequired().HasMaxLength(128);
            b.Property(a => a.AddressType).IsRequired().HasMaxLength(32);
            b.Property(a => a.Description).HasMaxLength(256);
            b.Property(a => a.BuildingOrFloor).HasMaxLength(128);
            b.Property(a => a.DeliveryNotes).HasMaxLength(256);
            b.HasIndex(a => a.CustomerId);
        });
    }
}
