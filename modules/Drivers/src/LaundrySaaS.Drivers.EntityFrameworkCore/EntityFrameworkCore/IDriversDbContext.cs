using LaundrySaaS.Drivers.Drivers;
using Microsoft.EntityFrameworkCore;
using Volo.Abp.Data;
using Volo.Abp.EntityFrameworkCore;

namespace LaundrySaaS.Drivers.EntityFrameworkCore;

[ConnectionStringName(DriversDbProperties.ConnectionStringName)]
public interface IDriversDbContext : IEfCoreDbContext
{
    DbSet<Driver> Drivers { get; }
}
