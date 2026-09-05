using Volo.Abp.Modularity;

namespace LaundrySaaS.Drivers;

/* Inherit from this class for your domain layer tests.
 * See SampleManager_Tests for example.
 */
public abstract class DriversDomainTestBase<TStartupModule> : DriversTestBase<TStartupModule>
    where TStartupModule : IAbpModule
{

}
