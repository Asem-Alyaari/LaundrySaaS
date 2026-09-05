using LaundrySaaS.Drivers.Localization;
using Volo.Abp.AspNetCore.Mvc;

namespace LaundrySaaS.Drivers;

public abstract class DriversController : AbpControllerBase
{
    protected DriversController()
    {
        LocalizationResource = typeof(DriversResource);
    }
}
