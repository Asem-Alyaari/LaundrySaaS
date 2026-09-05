using Volo.Abp.Autofac;
using Volo.Abp.Http.Client.IdentityModel;
using Volo.Abp.Modularity;

namespace LaundrySaaS;

[DependsOn(
    typeof(AbpAutofacModule),
    typeof(LaundrySaaSHttpApiClientModule),
    typeof(AbpHttpClientIdentityModelModule)
    )]
public class LaundrySaaSConsoleApiClientModule : AbpModule
{

}
