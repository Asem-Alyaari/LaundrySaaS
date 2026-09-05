using Microsoft.Extensions.DependencyInjection;
using Volo.Abp.Mapperly;
using Volo.Abp.Modularity;
using Volo.Abp.Application;

using LaundrySaaS.Customers;
using LaundrySaaS.Drivers;
using LaundrySaaS.Orders;
using LaundrySaaS.Laundries;

namespace LaundrySaaS;

[DependsOn(
    typeof(LaundrySaaSDomainModule),
    typeof(LaundrySaaSApplicationContractsModule),
    typeof(AbpDddApplicationModule),
    typeof(AbpMapperlyModule),
    typeof(CustomersApplicationModule),
    typeof(CustomersDomainModule),
    typeof(DriversApplicationModule),
    typeof(DriversDomainModule),
    typeof(OrdersApplicationModule),
    typeof(OrdersDomainModule),
    typeof(LaundriesApplicationModule),
    typeof(LaundriesDomainModule)
    )]
public class LaundrySaaSApplicationModule : AbpModule
{
    public override void ConfigureServices(ServiceConfigurationContext context)
    {
        context.Services.AddMapperlyObjectMapper<LaundrySaaSApplicationModule>();
    }
}
