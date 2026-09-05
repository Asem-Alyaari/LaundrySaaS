using LaundrySaaS.Localization;
using Volo.Abp.AspNetCore.Components;

namespace LaundrySaaS.Blazor.Server.Host;

public abstract class LaundrySaaSComponentBase : AbpComponentBase
{
    protected LaundrySaaSComponentBase()
    {
        LocalizationResource = typeof(LaundrySaaSResource);
    }
}
