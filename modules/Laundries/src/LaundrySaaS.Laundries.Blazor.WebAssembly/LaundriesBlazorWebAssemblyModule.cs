using Volo.Abp.AspNetCore.Components.WebAssembly.Theming.MudBlazor;
using Volo.Abp.Modularity;

namespace LaundrySaaS.Laundries.Blazor.WebAssembly;

[DependsOn(
    typeof(LaundriesBlazorModule),
    typeof(LaundriesHttpApiClientModule),
    typeof(AbpAspNetCoreComponentsWebAssemblyThemingMudBlazorModule)
    )]
public class LaundriesBlazorWebAssemblyModule : AbpModule
{

}
