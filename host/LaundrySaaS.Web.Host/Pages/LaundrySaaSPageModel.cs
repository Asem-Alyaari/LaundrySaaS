using LaundrySaaS.Localization;
using Volo.Abp.AspNetCore.Mvc.UI.RazorPages;

namespace LaundrySaaS.Pages;

public abstract class LaundrySaaSPageModel : AbpPageModel
{
    protected LaundrySaaSPageModel()
    {
        LocalizationResourceType = typeof(LaundrySaaSResource);
    }
}
