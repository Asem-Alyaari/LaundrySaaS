using System;
using Volo.Abp.Domain.Repositories;

namespace LaundrySaaS.Laundries.Items;

public interface IServiceItemRepository : IRepository<ServiceItem, Guid>
{
}
