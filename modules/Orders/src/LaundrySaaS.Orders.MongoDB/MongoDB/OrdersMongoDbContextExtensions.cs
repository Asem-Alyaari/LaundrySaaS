using Volo.Abp;
using Volo.Abp.MongoDB;

namespace LaundrySaaS.Orders.MongoDB;

public static class OrdersMongoDbContextExtensions
{
    public static void ConfigureOrders(
        this IMongoModelBuilder builder)
    {
        Check.NotNull(builder, nameof(builder));
    }
}
