using LaundrySaaS.Localization;
using Volo.Abp.AspNetCore.Mvc;

namespace LaundrySaaS;

public abstract class LaundrySaaSController : AbpControllerBase
{
    protected LaundrySaaSController()
    {
        LocalizationResource = typeof(LaundrySaaSResource);
    }
}
