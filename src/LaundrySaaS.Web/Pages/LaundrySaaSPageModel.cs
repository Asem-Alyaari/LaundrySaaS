using LaundrySaaS.Localization;
using Volo.Abp.AspNetCore.Mvc.UI.RazorPages;

namespace LaundrySaaS.Web.Pages;

/* Inherit your PageModel classes from this class.
 */
public abstract class LaundrySaaSPageModel : AbpPageModel
{
    protected LaundrySaaSPageModel()
    {
        LocalizationResourceType = typeof(LaundrySaaSResource);
        ObjectMapperContext = typeof(LaundrySaaSWebModule);
    }
}
