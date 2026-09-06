using Volo.Abp.Autofac;
using Volo.Abp.Http.Client.IdentityModel;
using Volo.Abp.Modularity;

namespace LaundrySaaS.Accounting;

[DependsOn(
    typeof(AbpAutofacModule),
    typeof(AccountingHttpApiClientModule),
    typeof(AbpHttpClientIdentityModelModule)
    )]
public class AccountingConsoleApiClientModule : AbpModule
{

}
