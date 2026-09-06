using Volo.Abp.Modularity;

namespace LaundrySaaS.Accounting;

[DependsOn(
    typeof(AccountingApplicationModule),
    typeof(AccountingDomainTestModule)
    )]
public class AccountingApplicationTestModule : AbpModule
{

}
