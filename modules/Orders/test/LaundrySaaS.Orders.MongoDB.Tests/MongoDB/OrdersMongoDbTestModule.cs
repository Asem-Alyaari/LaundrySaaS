using System;
using Volo.Abp.Data;
using Volo.Abp.Modularity;
using Volo.Abp.Uow;

namespace LaundrySaaS.Orders.MongoDB;

[DependsOn(
    typeof(OrdersApplicationTestModule),
    typeof(OrdersMongoDbModule)
)]
public class OrdersMongoDbTestModule : AbpModule
{
    public override void ConfigureServices(ServiceConfigurationContext context)
    {
        Configure<AbpDbConnectionOptions>(options =>
        {
            options.ConnectionStrings.Default = MongoDbFixture.GetRandomConnectionString();
        });
    }
}
