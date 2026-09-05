using Localization.Resources.AbpUi;
using LaundrySaaS.Localization;
using Volo.Abp.AspNetCore.Mvc;
using Volo.Abp.Localization;
using Volo.Abp.Modularity;
using Microsoft.Extensions.DependencyInjection;

namespace LaundrySaaS;

[DependsOn(
    typeof(LaundrySaaSApplicationContractsModule),
    typeof(AbpAspNetCoreMvcModule))]
public class LaundrySaaSHttpApiModule : AbpModule
{
    public override void PreConfigureServices(ServiceConfigurationContext context)
    {
        PreConfigure<IMvcBuilder>(mvcBuilder =>
        {
            mvcBuilder.AddApplicationPartIfNotExists(typeof(LaundrySaaSHttpApiModule).Assembly);
        });
    }

    public override void ConfigureServices(ServiceConfigurationContext context)
    {
        Configure<AbpLocalizationOptions>(options =>
        {
            options.Resources
                .Get<LaundrySaaSResource>()
                .AddBaseTypes(typeof(AbpUiResource));
        });
    }
}
