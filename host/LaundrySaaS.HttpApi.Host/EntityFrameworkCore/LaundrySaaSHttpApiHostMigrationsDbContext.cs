using LaundrySaaS.Customers.EntityFrameworkCore;
using LaundrySaaS.Drivers.EntityFrameworkCore;
using LaundrySaaS.Orders.EntityFrameworkCore;
using LaundrySaaS.Laundries.EntityFrameworkCore;
using LaundrySaaS.Accounting.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using Volo.Abp.EntityFrameworkCore;
using Volo.Abp.SettingManagement.EntityFrameworkCore;
using Volo.Abp.PermissionManagement.EntityFrameworkCore;
using Volo.Abp.AuditLogging.EntityFrameworkCore;
using Volo.Abp.TenantManagement.EntityFrameworkCore;

namespace LaundrySaaS.EntityFrameworkCore;

public class LaundrySaaSHttpApiHostMigrationsDbContext : AbpDbContext<LaundrySaaSHttpApiHostMigrationsDbContext>
{
    public LaundrySaaSHttpApiHostMigrationsDbContext(DbContextOptions<LaundrySaaSHttpApiHostMigrationsDbContext> options)
        : base(options)
    {

    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.ConfigureLaundrySaaS();
        modelBuilder.ConfigureCustomers();
        modelBuilder.ConfigureLaundries();
        modelBuilder.ConfigureDrivers();
        modelBuilder.ConfigureOrders();
        modelBuilder.ConfigureAccounting();
        modelBuilder.ConfigureSettingManagement();
        modelBuilder.ConfigurePermissionManagement();
        modelBuilder.ConfigureAuditLogging();
        modelBuilder.ConfigureTenantManagement();
    }
}
