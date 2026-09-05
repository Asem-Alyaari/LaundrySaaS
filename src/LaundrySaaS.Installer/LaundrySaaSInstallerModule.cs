using Volo.Abp.Modularity;
using Volo.Abp.VirtualFileSystem;

namespace LaundrySaaS;

[DependsOn(
    typeof(AbpVirtualFileSystemModule)
    )]
public class LaundrySaaSInstallerModule : AbpModule
{
    public override void ConfigureServices(ServiceConfigurationContext context)
    {
        Configure<AbpVirtualFileSystemOptions>(options =>
        {
            options.FileSets.AddEmbedded<LaundrySaaSInstallerModule>();
        });
    }
}
