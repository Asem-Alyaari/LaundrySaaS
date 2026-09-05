using Microsoft.Extensions.DependencyInjection;
using Volo.Abp.Http.Client;
using Volo.Abp.Modularity;
using Volo.Abp.VirtualFileSystem;

namespace LaundrySaaS.Laundries;

[DependsOn(
    typeof(LaundriesApplicationContractsModule),
    typeof(AbpHttpClientModule))]
public class LaundriesHttpApiClientModule : AbpModule
{
    public override void ConfigureServices(ServiceConfigurationContext context)
    {
        context.Services.AddHttpClientProxies(
            typeof(LaundriesApplicationContractsModule).Assembly,
            LaundriesRemoteServiceConsts.RemoteServiceName
        );

        Configure<AbpVirtualFileSystemOptions>(options =>
        {
            options.FileSets.AddEmbedded<LaundriesHttpApiClientModule>();
        });

    }
}
