using LaundrySaaS.Customers.Localization;
using Volo.Abp.AspNetCore.Mvc;

namespace LaundrySaaS.Customers;

public abstract class CustomersController : AbpControllerBase
{
    protected CustomersController()
    {
        LocalizationResource = typeof(CustomersResource);
    }
}
