using Localization.Resources.AbpUi;
using LaundrySaaS.Laundries.Localization;
using Volo.Abp.AspNetCore.Mvc;
using Volo.Abp.Localization;
using Volo.Abp.Modularity;
using Microsoft.Extensions.DependencyInjection;

namespace LaundrySaaS.Laundries;

[DependsOn(
    typeof(LaundriesApplicationContractsModule),
    typeof(AbpAspNetCoreMvcModule))]
public class LaundriesHttpApiModule : AbpModule
{
    public override void PreConfigureServices(ServiceConfigurationContext context)
    {
        PreConfigure<IMvcBuilder>(mvcBuilder =>
        {
            mvcBuilder.AddApplicationPartIfNotExists(typeof(LaundriesHttpApiModule).Assembly);
        });
    }

    public override void ConfigureServices(ServiceConfigurationContext context)
    {
        Configure<AbpLocalizationOptions>(options =>
        {
            options.Resources
                .Get<LaundriesResource>()
                .AddBaseTypes(typeof(AbpUiResource));
        });
    }
}
