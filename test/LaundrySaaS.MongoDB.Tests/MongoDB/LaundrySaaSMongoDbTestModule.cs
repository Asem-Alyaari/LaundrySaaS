using System;
using Volo.Abp.Data;
using Volo.Abp.Modularity;
using Volo.Abp.Uow;

namespace LaundrySaaS.MongoDB;

[DependsOn(
    typeof(LaundrySaaSApplicationTestModule),
    typeof(LaundrySaaSMongoDbModule)
)]
public class LaundrySaaSMongoDbTestModule : AbpModule
{
    public override void ConfigureServices(ServiceConfigurationContext context)
    {
        Configure<AbpDbConnectionOptions>(options =>
        {
            options.ConnectionStrings.Default = MongoDbFixture.GetRandomConnectionString();
        });
    }
}
