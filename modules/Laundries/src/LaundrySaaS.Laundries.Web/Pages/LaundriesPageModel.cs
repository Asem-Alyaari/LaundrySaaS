using LaundrySaaS.Laundries.Localization;
using Volo.Abp.AspNetCore.Mvc.UI.RazorPages;

namespace LaundrySaaS.Laundries.Web.Pages;

/* Inherit your PageModel classes from this class.
 */
public abstract class LaundriesPageModel : AbpPageModel
{
    protected LaundriesPageModel()
    {
        LocalizationResourceType = typeof(LaundriesResource);
        ObjectMapperContext = typeof(LaundriesWebModule);
    }
}
