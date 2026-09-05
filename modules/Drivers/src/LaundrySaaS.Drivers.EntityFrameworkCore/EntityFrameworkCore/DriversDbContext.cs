using LaundrySaaS.Drivers.Drivers;
using Microsoft.EntityFrameworkCore;
using Volo.Abp.Data;
using Volo.Abp.EntityFrameworkCore;

namespace LaundrySaaS.Drivers.EntityFrameworkCore;

[ConnectionStringName(DriversDbProperties.ConnectionStringName)]
public class DriversDbContext : AbpDbContext<DriversDbContext>, IDriversDbContext
{
    public DbSet<Driver> Drivers { get; set; } = null!;

    public DriversDbContext(DbContextOptions<DriversDbContext> options)
        : base(options)
    {

    }

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);

        builder.ConfigureDrivers();
    }
}
