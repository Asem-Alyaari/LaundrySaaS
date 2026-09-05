using LaundrySaaS.Laundries.Localization;
using Volo.Abp.Application.Services;

namespace LaundrySaaS.Laundries;

public abstract class LaundriesAppService : ApplicationService
{
    protected LaundriesAppService()
    {
        LocalizationResource = typeof(LaundriesResource);
        ObjectMapperContext = typeof(LaundriesApplicationModule);
    }
}
