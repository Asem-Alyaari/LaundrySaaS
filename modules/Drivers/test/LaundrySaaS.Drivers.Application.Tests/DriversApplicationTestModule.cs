using Volo.Abp.Modularity;

namespace LaundrySaaS.Drivers;

[DependsOn(
    typeof(DriversApplicationModule),
    typeof(DriversDomainTestModule)
    )]
public class DriversApplicationTestModule : AbpModule
{

}
