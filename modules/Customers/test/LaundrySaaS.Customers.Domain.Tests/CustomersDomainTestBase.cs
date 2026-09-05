using Volo.Abp.Modularity;

namespace LaundrySaaS.Customers;

/* Inherit from this class for your domain layer tests.
 * See SampleManager_Tests for example.
 */
public abstract class CustomersDomainTestBase<TStartupModule> : CustomersTestBase<TStartupModule>
    where TStartupModule : IAbpModule
{

}
