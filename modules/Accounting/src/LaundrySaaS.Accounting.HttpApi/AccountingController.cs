using LaundrySaaS.Accounting.Localization;
using Volo.Abp.AspNetCore.Mvc;

namespace LaundrySaaS.Accounting;

public abstract class AccountingController : AbpControllerBase
{
    protected AccountingController()
    {
        LocalizationResource = typeof(AccountingResource);
    }
}
