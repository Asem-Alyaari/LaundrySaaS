using Volo.Abp.Domain;
using Volo.Abp.Modularity;

namespace LaundrySaaS.Orders;

[DependsOn(
    typeof(AbpDddDomainModule),
    typeof(OrdersDomainSharedModule),
    typeof(LaundrySaaSDomainModule)
)]
public class OrdersDomainModule : AbpModule
{

}
