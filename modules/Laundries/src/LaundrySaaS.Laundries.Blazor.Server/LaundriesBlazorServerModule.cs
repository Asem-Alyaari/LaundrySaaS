using Volo.Abp.AspNetCore.Components.Server.Theming.MudBlazor;
using Volo.Abp.Modularity;

namespace LaundrySaaS.Laundries.Blazor.Server;

[DependsOn(
    typeof(AbpAspNetCoreComponentsServerThemingMudBlazorModule),
    typeof(LaundriesBlazorModule)
    )]
public class LaundriesBlazorServerModule : AbpModule
{

}
