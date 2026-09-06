using Volo.Abp.Modularity;

namespace LaundrySaaS.Accounting;

[DependsOn(
    typeof(AccountingDomainModule),
    typeof(AccountingTestBaseModule)
)]
public class AccountingDomainTestModule : AbpModule
{

}
