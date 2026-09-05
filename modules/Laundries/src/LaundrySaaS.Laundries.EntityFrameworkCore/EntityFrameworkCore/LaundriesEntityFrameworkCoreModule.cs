using LaundrySaaS.Laundries.Categories;
using LaundrySaaS.Laundries.Items;
using LaundrySaaS.Laundries.Laundries;
using Microsoft.Extensions.DependencyInjection;
using Volo.Abp.EntityFrameworkCore;
using Volo.Abp.Modularity;

namespace LaundrySaaS.Laundries.EntityFrameworkCore;

[DependsOn(
    typeof(LaundriesDomainModule),
    typeof(AbpEntityFrameworkCoreModule)
)]
public class LaundriesEntityFrameworkCoreModule : AbpModule
{
    public override void ConfigureServices(ServiceConfigurationContext context)
    {
        context.Services.AddAbpDbContext<LaundriesDbContext>(options =>
        {
            options.AddDefaultRepositories(includeAllEntities: true);
            options.AddRepository<Laundry, EfCoreLaundryRepository>();
            options.AddRepository<ServiceCategory, EfCoreServiceCategoryRepository>();
            options.AddRepository<ServiceItem, EfCoreServiceItemRepository>();
        });
    }
}
