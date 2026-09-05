using Microsoft.EntityFrameworkCore;
using Volo.Abp.EntityFrameworkCore;

namespace LaundrySaaS.Drivers.EntityFrameworkCore;

public class DriversHttpApiHostMigrationsDbContext : AbpDbContext<DriversHttpApiHostMigrationsDbContext>
{
    public DriversHttpApiHostMigrationsDbContext(DbContextOptions<DriversHttpApiHostMigrationsDbContext> options)
        : base(options)
    {

    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.ConfigureDrivers();
    }
}
