using Volo.Abp.Modularity;

namespace LaundrySaaS.Orders;

/* Inherit from this class for your domain layer tests.
 * See SampleManager_Tests for example.
 */
public abstract class OrdersDomainTestBase<TStartupModule> : OrdersTestBase<TStartupModule>
    where TStartupModule : IAbpModule
{

}
