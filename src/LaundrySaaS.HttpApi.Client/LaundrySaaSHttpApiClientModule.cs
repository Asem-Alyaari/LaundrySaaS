using Microsoft.Extensions.DependencyInjection;
using Volo.Abp.Http.Client;
using Volo.Abp.Modularity;
using Volo.Abp.VirtualFileSystem;

namespace LaundrySaaS;

[DependsOn(
    typeof(LaundrySaaSApplicationContractsModule),
    typeof(AbpHttpClientModule))]
public class LaundrySaaSHttpApiClientModule : AbpModule
{
    public override void ConfigureServices(ServiceConfigurationContext context)
    {
        context.Services.AddHttpClientProxies(
            typeof(LaundrySaaSApplicationContractsModule).Assembly,
            LaundrySaaSRemoteServiceConsts.RemoteServiceName
        );

        Configure<AbpVirtualFileSystemOptions>(options =>
        {
            options.FileSets.AddEmbedded<LaundrySaaSHttpApiClientModule>();
        });

    }
}
