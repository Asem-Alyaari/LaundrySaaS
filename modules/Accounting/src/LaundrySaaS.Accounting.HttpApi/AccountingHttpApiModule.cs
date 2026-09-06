using Localization.Resources.AbpUi;
using LaundrySaaS.Accounting.Localization;
using Volo.Abp.AspNetCore.Mvc;
using Volo.Abp.Localization;
using Volo.Abp.Modularity;
using Microsoft.Extensions.DependencyInjection;

namespace LaundrySaaS.Accounting;

[DependsOn(
    typeof(AccountingApplicationContractsModule),
    typeof(AbpAspNetCoreMvcModule))]
public class AccountingHttpApiModule : AbpModule
{
    public override void PreConfigureServices(ServiceConfigurationContext context)
    {
        PreConfigure<IMvcBuilder>(mvcBuilder =>
        {
            mvcBuilder.AddApplicationPartIfNotExists(typeof(AccountingHttpApiModule).Assembly);
        });
    }

    public override void ConfigureServices(ServiceConfigurationContext context)
    {
        Configure<AbpLocalizationOptions>(options =>
        {
            options.Resources
                .Get<AccountingResource>()
                .AddBaseTypes(typeof(AbpUiResource));
        });
    }
}
