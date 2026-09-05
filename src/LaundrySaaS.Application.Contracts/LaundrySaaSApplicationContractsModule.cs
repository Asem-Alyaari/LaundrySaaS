using Volo.Abp.Application;
using Volo.Abp.Modularity;
using Volo.Abp.Authorization;

namespace LaundrySaaS;

[DependsOn(
    typeof(LaundrySaaSDomainSharedModule),
    typeof(AbpDddApplicationContractsModule),
    typeof(AbpAuthorizationModule)
    )]
public class LaundrySaaSApplicationContractsModule : AbpModule
{

}
