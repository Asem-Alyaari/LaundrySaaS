using Microsoft.Extensions.DependencyInjection;
using LaundrySaaS.Blazor.Menus;
using Volo.Abp.AspNetCore.Components.Web.Theming.MudBlazor;
using Volo.Abp.AspNetCore.Components.Web.Theming.MudBlazor.Routing;
using Volo.Abp.Mapperly;
using Volo.Abp.Modularity;
using Volo.Abp.UI.Navigation;

namespace LaundrySaaS.Blazor;

[DependsOn(
    typeof(LaundrySaaSApplicationContractsModule),
    typeof(AbpAspNetCoreComponentsWebThemingMudBlazorModule),
    typeof(AbpMapperlyModule)
    )]
public class LaundrySaaSBlazorModule : AbpModule
{
    public override void ConfigureServices(ServiceConfigurationContext context)
    {
        context.Services.AddMapperlyObjectMapper<LaundrySaaSBlazorModule>();

        Configure<AbpNavigationOptions>(options =>
        {
            options.MenuContributors.Add(new LaundrySaaSMenuContributor());
        });

        Configure<AbpRouterOptions>(options =>
        {
            options.AdditionalAssemblies.Add(typeof(LaundrySaaSBlazorModule).Assembly);
        });
    }
}
