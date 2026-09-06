using Volo.Abp.Domain;
using Volo.Abp.Modularity;

namespace LaundrySaaS.Accounting;

[DependsOn(
    typeof(AbpDddDomainModule),
    typeof(AccountingDomainSharedModule),
    typeof(LaundrySaaSDomainModule)
)]
public class AccountingDomainModule : AbpModule
{

}
