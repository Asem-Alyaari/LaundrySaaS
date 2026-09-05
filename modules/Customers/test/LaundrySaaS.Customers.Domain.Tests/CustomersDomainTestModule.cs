using Volo.Abp.Modularity;

namespace LaundrySaaS.Customers;

[DependsOn(
    typeof(CustomersDomainModule),
    typeof(CustomersTestBaseModule)
)]
public class CustomersDomainTestModule : AbpModule
{

}
