using Volo.Abp.Application;
using Volo.Abp.Modularity;
using Volo.Abp.Authorization;

namespace LaundrySaaS.Laundries;

[DependsOn(
    typeof(LaundriesDomainSharedModule),
    typeof(AbpDddApplicationContractsModule),
    typeof(AbpAuthorizationModule)
    )]
public class LaundriesApplicationContractsModule : AbpModule
{

}
