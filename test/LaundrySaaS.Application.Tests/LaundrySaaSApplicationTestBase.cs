using Volo.Abp.Modularity;

namespace LaundrySaaS;

/* Inherit from this class for your application layer tests.
 * See SampleAppService_Tests for example.
 */
public abstract class LaundrySaaSApplicationTestBase<TStartupModule> : LaundrySaaSTestBase<TStartupModule>
    where TStartupModule : IAbpModule
{

}
