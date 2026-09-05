using System;
using Volo.Abp.Domain.Repositories;

namespace LaundrySaaS.Orders.Orders;

public interface IOrderRepository : IRepository<Order, Guid>
{
}
