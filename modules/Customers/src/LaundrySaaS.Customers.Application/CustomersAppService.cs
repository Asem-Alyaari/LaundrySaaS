using LaundrySaaS.Customers.Localization;
using Volo.Abp.Application.Services;

namespace LaundrySaaS.Customers;

public abstract class CustomersAppService : ApplicationService
{
    protected CustomersAppService()
    {
        LocalizationResource = typeof(CustomersResource);
        ObjectMapperContext = typeof(CustomersApplicationModule);
    }
}
