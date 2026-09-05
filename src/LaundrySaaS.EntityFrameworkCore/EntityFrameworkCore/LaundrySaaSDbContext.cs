using Microsoft.EntityFrameworkCore;
using LaundrySaaS.Editions;
using LaundrySaaS.Subscriptions;
using Volo.Abp.Data;
using Volo.Abp.EntityFrameworkCore;

namespace LaundrySaaS.EntityFrameworkCore;

[ConnectionStringName(LaundrySaaSDbProperties.ConnectionStringName)]
public class LaundrySaaSDbContext : AbpDbContext<LaundrySaaSDbContext>, ILaundrySaaSDbContext
{
    public DbSet<Edition> Editions { get; set; } = null!;
    public DbSet<TenantSubscription> TenantSubscriptions { get; set; } = null!;

    public LaundrySaaSDbContext(DbContextOptions<LaundrySaaSDbContext> options)
        : base(options)
    {

    }

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);

        builder.ConfigureLaundrySaaS();
    }
}
