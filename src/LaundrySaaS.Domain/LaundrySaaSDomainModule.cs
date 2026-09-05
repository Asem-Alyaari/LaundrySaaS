using Volo.Abp.Domain;
using Volo.Abp.Modularity;

namespace LaundrySaaS;

[DependsOn(
    typeof(AbpDddDomainModule),
    typeof(LaundrySaaSDomainSharedModule)
)]
public class LaundrySaaSDomainModule : AbpModule
{

}
