using Volo.Abp.Modularity;
using Volo.Abp.VirtualFileSystem;

namespace LaundrySaaS.Accounting;

[DependsOn(
    typeof(AbpVirtualFileSystemModule)
    )]
public class AccountingInstallerModule : AbpModule
{
    public override void ConfigureServices(ServiceConfigurationContext context)
    {
        Configure<AbpVirtualFileSystemOptions>(options =>
        {
            options.FileSets.AddEmbedded<AccountingInstallerModule>();
        });
    }
}
