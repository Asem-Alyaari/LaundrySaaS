using LaundrySaaS.Laundries.Localization;
using Volo.Abp.AspNetCore.Mvc;

namespace LaundrySaaS.Laundries;

public abstract class LaundriesController : AbpControllerBase
{
    protected LaundriesController()
    {
        LocalizationResource = typeof(LaundriesResource);
    }
}
