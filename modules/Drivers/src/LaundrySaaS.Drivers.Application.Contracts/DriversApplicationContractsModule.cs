using Volo.Abp.Application;
using Volo.Abp.Modularity;
using Volo.Abp.Authorization;

namespace LaundrySaaS.Drivers;

[DependsOn(
    typeof(DriversDomainSharedModule),
    typeof(AbpDddApplicationContractsModule),
    typeof(AbpAuthorizationModule)
    )]
public class DriversApplicationContractsModule : AbpModule
{

}
