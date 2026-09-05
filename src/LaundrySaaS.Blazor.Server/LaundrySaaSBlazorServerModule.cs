using Volo.Abp.AspNetCore.Components.Server.Theming.MudBlazor;
using Volo.Abp.Modularity;

namespace LaundrySaaS.Blazor.Server;

[DependsOn(
    typeof(AbpAspNetCoreComponentsServerThemingMudBlazorModule),
    typeof(LaundrySaaSBlazorModule)
    )]
public class LaundrySaaSBlazorServerModule : AbpModule
{

}
