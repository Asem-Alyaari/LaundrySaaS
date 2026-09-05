using Volo.Abp.Autofac;
using Volo.Abp.Http.Client.IdentityModel;
using Volo.Abp.Modularity;

namespace LaundrySaaS.Drivers;

[DependsOn(
    typeof(AbpAutofacModule),
    typeof(DriversHttpApiClientModule),
    typeof(AbpHttpClientIdentityModelModule)
    )]
public class DriversConsoleApiClientModule : AbpModule
{

}
