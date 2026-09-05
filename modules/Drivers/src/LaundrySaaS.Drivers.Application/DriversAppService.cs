using LaundrySaaS.Drivers.Localization;
using Volo.Abp.Application.Services;

namespace LaundrySaaS.Drivers;

public abstract class DriversAppService : ApplicationService
{
    protected DriversAppService()
    {
        LocalizationResource = typeof(DriversResource);
        ObjectMapperContext = typeof(DriversApplicationModule);
    }
}
