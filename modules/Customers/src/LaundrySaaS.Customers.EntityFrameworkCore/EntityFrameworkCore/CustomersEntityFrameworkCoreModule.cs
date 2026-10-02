using LaundrySaaS.Customers.Customers;
using Microsoft.Extensions.DependencyInjection;
using Volo.Abp.EntityFrameworkCore;
using Volo.Abp.Modularity;

namespace LaundrySaaS.Customers.EntityFrameworkCore;

[DependsOn(
    typeof(CustomersDomainModule),
    typeof(AbpEntityFrameworkCoreModule)
)]
public class CustomersEntityFrameworkCoreModule : AbpModule
{
    public override void ConfigureServices(ServiceConfigurationContext context)
    {
        context.Services.AddAbpDbContext<CustomersDbContext>(options =>
        {
            options.AddDefaultRepositories(includeAllEntities: true);
            options.AddRepository<Customer, EfCoreCustomerRepository>();
        });
    }
}
