using System;
using Volo.Abp.Data;
using Volo.Abp.Modularity;
using Volo.Abp.Uow;

namespace LaundrySaaS.Accounting.MongoDB;

[DependsOn(
    typeof(AccountingApplicationTestModule),
    typeof(AccountingMongoDbModule)
)]
public class AccountingMongoDbTestModule : AbpModule
{
    public override void ConfigureServices(ServiceConfigurationContext context)
    {
        Configure<AbpDbConnectionOptions>(options =>
        {
            options.ConnectionStrings.Default = MongoDbFixture.GetRandomConnectionString();
        });
    }
}
