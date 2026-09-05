using Volo.Abp.Modularity;

namespace LaundrySaaS.Orders;

/* Inherit from this class for your application layer tests.
 * See SampleAppService_Tests for example.
 */
public abstract class OrdersApplicationTestBase<TStartupModule> : OrdersTestBase<TStartupModule>
    where TStartupModule : IAbpModule
{

}
