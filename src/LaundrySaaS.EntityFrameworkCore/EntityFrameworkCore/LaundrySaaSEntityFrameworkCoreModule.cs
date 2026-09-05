using Microsoft.Extensions.DependencyInjection;
using Volo.Abp.EntityFrameworkCore;
using Volo.Abp.Modularity;

namespace LaundrySaaS.EntityFrameworkCore;

[DependsOn(
    typeof(LaundrySaaSDomainModule),
    typeof(AbpEntityFrameworkCoreModule)
)]
public class LaundrySaaSEntityFrameworkCoreModule : AbpModule
{
    public override void ConfigureServices(ServiceConfigurationContext context)
    {
        context.Services.AddAbpDbContext<LaundrySaaSDbContext>(options =>
        {
            options.AddDefaultRepositories(includeAllEntities: true);
        });
    }
}
