using System;
using Volo.Abp.Data;
using Volo.Abp.Modularity;
using Volo.Abp.Uow;

namespace LaundrySaaS.Customers.MongoDB;

[DependsOn(
    typeof(CustomersApplicationTestModule),
    typeof(CustomersMongoDbModule)
)]
public class CustomersMongoDbTestModule : AbpModule
{
    public override void ConfigureServices(ServiceConfigurationContext context)
    {
        Configure<AbpDbConnectionOptions>(options =>
        {
            options.ConnectionStrings.Default = MongoDbFixture.GetRandomConnectionString();
        });
    }
}
