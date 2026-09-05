using Volo.Abp.Autofac;
using Volo.Abp.Http.Client.IdentityModel;
using Volo.Abp.Modularity;

namespace LaundrySaaS.Orders;

[DependsOn(
    typeof(AbpAutofacModule),
    typeof(OrdersHttpApiClientModule),
    typeof(AbpHttpClientIdentityModelModule)
    )]
public class OrdersConsoleApiClientModule : AbpModule
{

}
