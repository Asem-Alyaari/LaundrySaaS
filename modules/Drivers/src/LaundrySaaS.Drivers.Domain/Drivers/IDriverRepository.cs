using System;
using Volo.Abp.Domain.Repositories;

namespace LaundrySaaS.Drivers.Drivers;

public interface IDriverRepository : IRepository<Driver, Guid>
{
}
