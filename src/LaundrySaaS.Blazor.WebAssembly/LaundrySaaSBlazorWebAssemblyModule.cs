using Volo.Abp.AspNetCore.Components.WebAssembly.Theming.MudBlazor;
using Volo.Abp.Modularity;

namespace LaundrySaaS.Blazor.WebAssembly;

[DependsOn(
    typeof(LaundrySaaSBlazorModule),
    typeof(LaundrySaaSHttpApiClientModule),
    typeof(AbpAspNetCoreComponentsWebAssemblyThemingMudBlazorModule)
    )]
public class LaundrySaaSBlazorWebAssemblyModule : AbpModule
{

}
