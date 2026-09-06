using LaundrySaaS.Accounting.Localization;
using Volo.Abp.Application.Services;

namespace LaundrySaaS.Accounting;

public abstract class AccountingAppService : ApplicationService
{
    protected AccountingAppService()
    {
        LocalizationResource = typeof(AccountingResource);
        ObjectMapperContext = typeof(AccountingApplicationModule);
    }
}
