using Volo.Abp.Modularity;

namespace LaundrySaaS;

[DependsOn(
    typeof(LaundrySaaSDomainModule),
    typeof(LaundrySaaSTestBaseModule)
)]
public class LaundrySaaSDomainTestModule : AbpModule
{

}
