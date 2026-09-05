using LaundrySaaS.Drivers.Drivers;
using Microsoft.Extensions.DependencyInjection;
using Volo.Abp.EntityFrameworkCore;
using Volo.Abp.Modularity;

namespace LaundrySaaS.Drivers.EntityFrameworkCore;

[DependsOn(
    typeof(DriversDomainModule),
    typeof(AbpEntityFrameworkCoreModule)
)]
public class DriversEntityFrameworkCoreModule : AbpModule
{
    public override void ConfigureServices(ServiceConfigurationContext context)
    {
        context.Services.AddAbpDbContext<DriversDbContext>(options =>
        {
            options.AddRepository<Driver, EfCoreDriverRepository>();
        });
    }
}
