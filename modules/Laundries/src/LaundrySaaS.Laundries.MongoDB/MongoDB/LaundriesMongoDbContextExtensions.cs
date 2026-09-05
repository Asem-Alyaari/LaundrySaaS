using Volo.Abp;
using Volo.Abp.MongoDB;

namespace LaundrySaaS.Laundries.MongoDB;

public static class LaundriesMongoDbContextExtensions
{
    public static void ConfigureLaundries(
        this IMongoModelBuilder builder)
    {
        Check.NotNull(builder, nameof(builder));
    }
}
