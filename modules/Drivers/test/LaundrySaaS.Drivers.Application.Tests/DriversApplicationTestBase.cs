using Volo.Abp.Modularity;

namespace LaundrySaaS.Drivers;

/* Inherit from this class for your application layer tests.
 * See SampleAppService_Tests for example.
 */
public abstract class DriversApplicationTestBase<TStartupModule> : DriversTestBase<TStartupModule>
    where TStartupModule : IAbpModule
{

}
