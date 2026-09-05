using Volo.Abp.Modularity;

namespace LaundrySaaS.Customers;

/* Inherit from this class for your application layer tests.
 * See SampleAppService_Tests for example.
 */
public abstract class CustomersApplicationTestBase<TStartupModule> : CustomersTestBase<TStartupModule>
    where TStartupModule : IAbpModule
{

}
