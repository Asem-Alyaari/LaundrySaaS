using System;
using LaundrySaaS.Orders.Orders;
using Volo.Abp.Domain.Repositories.EntityFrameworkCore;
using Volo.Abp.EntityFrameworkCore;

namespace LaundrySaaS.Orders.EntityFrameworkCore;

public class EfCoreOrderRepository :
    EfCoreRepository<OrdersDbContext, Order, Guid>,
    IOrderRepository
{
    public EfCoreOrderRepository(IDbContextProvider<OrdersDbContext> dbContextProvider)
        : base(dbContextProvider)
    {
    }
}
