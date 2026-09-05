using LaundrySaaS.Localization;
using Volo.Abp.Application.Services;

namespace LaundrySaaS;

public abstract class LaundrySaaSAppService : ApplicationService
{
    protected LaundrySaaSAppService()
    {
        LocalizationResource = typeof(LaundrySaaSResource);
        ObjectMapperContext = typeof(LaundrySaaSApplicationModule);
    }
}
