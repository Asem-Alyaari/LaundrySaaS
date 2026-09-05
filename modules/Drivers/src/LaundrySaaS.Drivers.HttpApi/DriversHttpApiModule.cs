using Localization.Resources.AbpUi;
using LaundrySaaS.Drivers.Localization;
using Volo.Abp.AspNetCore.Mvc;
using Volo.Abp.Localization;
using Volo.Abp.Modularity;
using Microsoft.Extensions.DependencyInjection;

namespace LaundrySaaS.Drivers;

[DependsOn(
    typeof(DriversApplicationContractsModule),
    typeof(AbpAspNetCoreMvcModule))]
public class DriversHttpApiModule : AbpModule
{
    public override void PreConfigureServices(ServiceConfigurationContext context)
    {
        PreConfigure<IMvcBuilder>(mvcBuilder =>
        {
            mvcBuilder.AddApplicationPartIfNotExists(typeof(DriversHttpApiModule).Assembly);
        });
    }

    public override void ConfigureServices(ServiceConfigurationContext context)
    {
        Configure<AbpLocalizationOptions>(options =>
        {
            options.Resources
                .Get<DriversResource>()
                .AddBaseTypes(typeof(AbpUiResource));
        });
    }
}
