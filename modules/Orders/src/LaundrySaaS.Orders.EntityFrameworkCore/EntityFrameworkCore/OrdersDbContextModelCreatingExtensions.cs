using LaundrySaaS.Orders.Orders;
using Microsoft.EntityFrameworkCore;
using Volo.Abp;
using Volo.Abp.EntityFrameworkCore.Modeling;

namespace LaundrySaaS.Orders.EntityFrameworkCore;

public static class OrdersDbContextModelCreatingExtensions
{
    public static void ConfigureOrders(
        this ModelBuilder builder)
    {
        Check.NotNull(builder, nameof(builder));

        builder.Entity<Order>(b =>
        {
            b.ToTable(OrdersDbProperties.DbTablePrefix + "Orders", OrdersDbProperties.DbSchema);

            b.ConfigureByConvention();

            b.Property(o => o.CustomerId)
                .IsRequired();

            b.Property(o => o.DriverId)
                .IsRequired(false);

            b.Property(o => o.Status)
                .IsRequired();

            b.Property(o => o.TotalAmount)
                .IsRequired()
                .HasPrecision(18, 2);

            b.OwnsOne(o => o.DeliveryAddress, addr =>
            {
                addr.Property(a => a.City).IsRequired().HasMaxLength(64).HasColumnName("DeliveryAddress_City");
                addr.Property(a => a.District).IsRequired().HasMaxLength(64).HasColumnName("DeliveryAddress_District");
                addr.Property(a => a.Street).IsRequired().HasMaxLength(128).HasColumnName("DeliveryAddress_Street");
                addr.Property(a => a.BuildingNumber).IsRequired().HasMaxLength(16).HasColumnName("DeliveryAddress_BuildingNumber");
            });
        });
    }
}
