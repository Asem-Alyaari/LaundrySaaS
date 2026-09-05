using Volo.Abp.Modularity;

namespace LaundrySaaS;

/* Inherit from this class for your domain layer tests.
 * See SampleManager_Tests for example.
 */
public abstract class LaundrySaaSDomainTestBase<TStartupModule> : LaundrySaaSTestBase<TStartupModule>
    where TStartupModule : IAbpModule
{

}
