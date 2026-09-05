using Volo.Abp;
using Volo.Abp.MongoDB;

namespace LaundrySaaS.MongoDB;

public static class LaundrySaaSMongoDbContextExtensions
{
    public static void ConfigureLaundrySaaS(
        this IMongoModelBuilder builder)
    {
        Check.NotNull(builder, nameof(builder));
    }
}
