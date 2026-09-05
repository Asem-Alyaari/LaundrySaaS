using Volo.Abp.Modularity;
using Volo.Abp.VirtualFileSystem;

namespace LaundrySaaS.Orders;

[DependsOn(
    typeof(AbpVirtualFileSystemModule)
    )]
public class OrdersInstallerModule : AbpModule
{
    public override void ConfigureServices(ServiceConfigurationContext context)
    {
        Configure<AbpVirtualFileSystemOptions>(options =>
        {
            options.FileSets.AddEmbedded<OrdersInstallerModule>();
        });
    }
}
