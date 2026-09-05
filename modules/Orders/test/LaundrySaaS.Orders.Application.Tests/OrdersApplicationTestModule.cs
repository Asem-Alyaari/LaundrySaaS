using Volo.Abp.Modularity;

namespace LaundrySaaS.Orders;

[DependsOn(
    typeof(OrdersApplicationModule),
    typeof(OrdersDomainTestModule)
    )]
public class OrdersApplicationTestModule : AbpModule
{

}
