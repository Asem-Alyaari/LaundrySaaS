using Microsoft.Extensions.DependencyInjection;
using Volo.Abp.Http.Client;
using Volo.Abp.Modularity;
using Volo.Abp.VirtualFileSystem;

namespace LaundrySaaS.Orders;

[DependsOn(
    typeof(OrdersApplicationContractsModule),
    typeof(AbpHttpClientModule))]
public class OrdersHttpApiClientModule : AbpModule
{
    public override void ConfigureServices(ServiceConfigurationContext context)
    {
        context.Services.AddHttpClientProxies(
            typeof(OrdersApplicationContractsModule).Assembly,
            OrdersRemoteServiceConsts.RemoteServiceName
        );

        Configure<AbpVirtualFileSystemOptions>(options =>
        {
            options.FileSets.AddEmbedded<OrdersHttpApiClientModule>();
        });

    }
}
