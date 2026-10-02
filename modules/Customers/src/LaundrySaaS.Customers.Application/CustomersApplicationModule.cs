using Microsoft.Extensions.DependencyInjection;
using Volo.Abp.Mapperly;
using Volo.Abp.Modularity;
using Volo.Abp.Application;
using Volo.Abp.Identity;

namespace LaundrySaaS.Customers;

[DependsOn(
    typeof(CustomersDomainModule),
    typeof(CustomersApplicationContractsModule),
    typeof(AbpDddApplicationModule),
    typeof(AbpIdentityDomainModule),
    typeof(AbpMapperlyModule)
    )]
public class CustomersApplicationModule : AbpModule
{
    public override void ConfigureServices(ServiceConfigurationContext context)
    {
        context.Services.AddMapperlyObjectMapper<CustomersApplicationModule>();
    }
}
