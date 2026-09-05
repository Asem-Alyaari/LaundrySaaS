using Volo.Abp.Modularity;

namespace LaundrySaaS.Customers;

[DependsOn(
    typeof(CustomersApplicationModule),
    typeof(CustomersDomainTestModule)
    )]
public class CustomersApplicationTestModule : AbpModule
{

}
