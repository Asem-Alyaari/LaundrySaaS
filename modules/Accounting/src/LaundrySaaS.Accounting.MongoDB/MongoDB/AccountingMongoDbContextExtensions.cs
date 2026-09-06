using Volo.Abp;
using Volo.Abp.MongoDB;

namespace LaundrySaaS.Accounting.MongoDB;

public static class AccountingMongoDbContextExtensions
{
    public static void ConfigureAccounting(
        this IMongoModelBuilder builder)
    {
        Check.NotNull(builder, nameof(builder));
    }
}
