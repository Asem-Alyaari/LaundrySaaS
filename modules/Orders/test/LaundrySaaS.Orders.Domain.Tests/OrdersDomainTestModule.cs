using Volo.Abp.Modularity;

namespace LaundrySaaS.Orders;

[DependsOn(
    typeof(OrdersDomainModule),
    typeof(OrdersTestBaseModule)
)]
public class OrdersDomainTestModule : AbpModule
{

}
