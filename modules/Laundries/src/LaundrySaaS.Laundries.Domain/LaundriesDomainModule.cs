using Volo.Abp.Domain;
using Volo.Abp.Modularity;

namespace LaundrySaaS.Laundries;

[DependsOn(
    typeof(AbpDddDomainModule),
    typeof(LaundriesDomainSharedModule),
    typeof(LaundrySaaSDomainModule)
)]
public class LaundriesDomainModule : AbpModule
{

}
