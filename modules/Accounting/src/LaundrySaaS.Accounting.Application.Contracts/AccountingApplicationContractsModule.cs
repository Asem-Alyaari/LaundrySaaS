using Volo.Abp.Application;
using Volo.Abp.Modularity;
using Volo.Abp.Authorization;

namespace LaundrySaaS.Accounting;

[DependsOn(
    typeof(AccountingDomainSharedModule),
    typeof(AbpDddApplicationContractsModule),
    typeof(AbpAuthorizationModule)
    )]
public class AccountingApplicationContractsModule : AbpModule
{

}
