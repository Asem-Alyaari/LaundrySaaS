using Volo.Abp.Modularity;
using Volo.Abp.VirtualFileSystem;

namespace LaundrySaaS.Drivers;

[DependsOn(
    typeof(AbpVirtualFileSystemModule)
    )]
public class DriversInstallerModule : AbpModule
{
    public override void ConfigureServices(ServiceConfigurationContext context)
    {
        Configure<AbpVirtualFileSystemOptions>(options =>
        {
            options.FileSets.AddEmbedded<DriversInstallerModule>();
        });
    }
}
