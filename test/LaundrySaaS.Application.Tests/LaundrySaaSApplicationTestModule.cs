using Volo.Abp.Modularity;

namespace LaundrySaaS;

[DependsOn(
    typeof(LaundrySaaSApplicationModule),
    typeof(LaundrySaaSDomainTestModule)
    )]
public class LaundrySaaSApplicationTestModule : AbpModule
{

}
