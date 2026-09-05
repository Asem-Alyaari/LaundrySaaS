using Microsoft.EntityFrameworkCore;
using LaundrySaaS.Editions;
using LaundrySaaS.Subscriptions;
using Volo.Abp.Data;
using Volo.Abp.EntityFrameworkCore;

namespace LaundrySaaS.EntityFrameworkCore;

[ConnectionStringName(LaundrySaaSDbProperties.ConnectionStringName)]
public interface ILaundrySaaSDbContext : IEfCoreDbContext
{
    DbSet<Edition> Editions { get; }
    DbSet<TenantSubscription> TenantSubscriptions { get; }
}
