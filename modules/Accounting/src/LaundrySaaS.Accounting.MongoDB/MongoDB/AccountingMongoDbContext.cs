using Volo.Abp.Data;
using Volo.Abp.MongoDB;

namespace LaundrySaaS.Accounting.MongoDB;

[ConnectionStringName(AccountingDbProperties.ConnectionStringName)]
public class AccountingMongoDbContext : AbpMongoDbContext, IAccountingMongoDbContext
{
    /* Add mongo collections here. Example:
     * public IMongoCollection<Question> Questions => Collection<Question>();
     */

    protected override void CreateModel(IMongoModelBuilder modelBuilder)
    {
        base.CreateModel(modelBuilder);

        modelBuilder.ConfigureAccounting();
    }
}
