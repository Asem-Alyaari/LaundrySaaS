using LaundrySaaS.Orders.Orders;
using Microsoft.EntityFrameworkCore;
using Volo.Abp.Data;
using Volo.Abp.EntityFrameworkCore;

namespace LaundrySaaS.Orders.EntityFrameworkCore;

[ConnectionStringName(OrdersDbProperties.ConnectionStringName)]
public class OrdersDbContext : AbpDbContext<OrdersDbContext>, IOrdersDbContext
{
    public DbSet<Order> Orders { get; set; } = null!;
    public DbSet<OrderItem> OrderItems { get; set; } = null!;

    public OrdersDbContext(DbContextOptions<OrdersDbContext> options)
        : base(options)
    {

    }

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);

        builder.ConfigureOrders();
    }
}
