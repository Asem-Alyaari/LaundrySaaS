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

            b.Property(o => o.TenantId)
                .IsRequired(false);

            b.Property(o => o.LaundryId)
                .IsRequired();

            b.Property(o => o.OrderNumber)
                .IsRequired()
                .HasMaxLength(64);

            b.Property(o => o.IsWalkIn)
                .IsRequired();

            b.Property(o => o.CustomerId)
                .IsRequired(false);

            b.Property(o => o.CustomerName)
                .IsRequired()
                .HasMaxLength(128);

            b.Property(o => o.CustomerPhoneNumber)
                .IsRequired(false)
                .HasMaxLength(32);

            b.Property(o => o.DeliveryType)
                .IsRequired();

            b.Property(o => o.DriverId)
                .IsRequired(false);

            b.Property(o => o.Status)
                .IsRequired();

            b.Property(o => o.PaymentStatus)
                .IsRequired();

            b.Property(o => o.PaymentMethod)
                .IsRequired();

            b.Property(o => o.Subtotal)
                .IsRequired()
                .HasPrecision(18, 2);

            b.Property(o => o.DiscountAmount)
                .IsRequired()
                .HasPrecision(18, 2);

            b.Property(o => o.TaxAmount)
                .IsRequired()
                .HasPrecision(18, 2);

            b.Property(o => o.TotalAmount)
                .IsRequired()
                .HasPrecision(18, 2);

            b.Property(o => o.Notes)
                .IsRequired(false)
                .HasMaxLength(512);

            b.OwnsOne(o => o.DeliveryAddress, addr =>
            {
                addr.Property(a => a.City).HasMaxLength(64).HasColumnName("DeliveryAddress_City");
                addr.Property(a => a.District).HasMaxLength(64).HasColumnName("DeliveryAddress_District");
                addr.Property(a => a.Street).HasMaxLength(128).HasColumnName("DeliveryAddress_Street");
                addr.Property(a => a.BuildingNumber).HasMaxLength(16).HasColumnName("DeliveryAddress_BuildingNumber");
            });

            b.HasMany(o => o.Items)
                .WithOne()
                .HasForeignKey(i => i.OrderId)
                .IsRequired()
                .OnDelete(DeleteBehavior.Cascade);

            b.HasIndex(o => o.LaundryId);
            b.HasIndex(o => o.OrderNumber);
            b.HasIndex(o => o.TenantId);
        });

        builder.Entity<OrderItem>(b =>
        {
            b.ToTable(OrdersDbProperties.DbTablePrefix + "OrderItems", OrdersDbProperties.DbSchema);

            b.ConfigureByConvention();

            b.Property(i => i.OrderId)
                .IsRequired();

            b.Property(i => i.ServiceItemId)
                .IsRequired();

            b.Property(i => i.ItemName)
                .IsRequired()
                .HasMaxLength(128);

            b.Property(i => i.UnitPrice)
                .IsRequired()
                .HasPrecision(18, 2);

            b.Property(i => i.Quantity)
                .IsRequired();

            b.Property(i => i.TotalPrice)
                .IsRequired()
                .HasPrecision(18, 2);

            b.Property(i => i.Notes)
                .IsRequired(false)
                .HasMaxLength(256);

            b.HasIndex(i => i.OrderId);
            b.HasIndex(i => i.ServiceItemId);
        });
    }
}
