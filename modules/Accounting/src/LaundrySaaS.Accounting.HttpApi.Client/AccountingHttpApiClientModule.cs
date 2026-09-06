using Microsoft.Extensions.DependencyInjection;
using Volo.Abp.Http.Client;
using Volo.Abp.Modularity;
using Volo.Abp.VirtualFileSystem;

namespace LaundrySaaS.Accounting;

[DependsOn(
    typeof(AccountingApplicationContractsModule),
    typeof(AbpHttpClientModule))]
public class AccountingHttpApiClientModule : AbpModule
{
    public override void ConfigureServices(ServiceConfigurationContext context)
    {
        context.Services.AddHttpClientProxies(
            typeof(AccountingApplicationContractsModule).Assembly,
            AccountingRemoteServiceConsts.RemoteServiceName
        );

        Configure<AbpVirtualFileSystemOptions>(options =>
        {
            options.FileSets.AddEmbedded<AccountingHttpApiClientModule>();
        });

    }
}
