using LaundrySaaS.Orders.Orders;
using Microsoft.EntityFrameworkCore;
using Volo.Abp.Data;
using Volo.Abp.EntityFrameworkCore;

namespace LaundrySaaS.Orders.EntityFrameworkCore;

[ConnectionStringName(OrdersDbProperties.ConnectionStringName)]
public interface IOrdersDbContext : IEfCoreDbContext
{
    DbSet<Order> Orders { get; }
}
