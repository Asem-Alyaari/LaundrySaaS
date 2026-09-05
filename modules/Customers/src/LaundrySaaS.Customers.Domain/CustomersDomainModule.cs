using Volo.Abp.Domain;
using Volo.Abp.Modularity;

namespace LaundrySaaS.Customers;

[DependsOn(
    typeof(AbpDddDomainModule),
    typeof(CustomersDomainSharedModule),
    typeof(LaundrySaaSDomainModule)
)]
public class CustomersDomainModule : AbpModule
{

}
