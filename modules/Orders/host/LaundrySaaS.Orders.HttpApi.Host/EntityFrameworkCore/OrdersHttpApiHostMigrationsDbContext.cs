using Microsoft.EntityFrameworkCore;
using Volo.Abp.EntityFrameworkCore;

namespace LaundrySaaS.Orders.EntityFrameworkCore;

public class OrdersHttpApiHostMigrationsDbContext : AbpDbContext<OrdersHttpApiHostMigrationsDbContext>
{
    public OrdersHttpApiHostMigrationsDbContext(DbContextOptions<OrdersHttpApiHostMigrationsDbContext> options)
        : base(options)
    {

    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.ConfigureOrders();
    }
}
