using Volo.Abp.Modularity;

namespace LaundrySaaS.Drivers;

[DependsOn(
    typeof(DriversDomainModule),
    typeof(DriversTestBaseModule)
)]
public class DriversDomainTestModule : AbpModule
{

}
