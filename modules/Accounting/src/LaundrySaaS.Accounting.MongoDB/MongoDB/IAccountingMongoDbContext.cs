using Volo.Abp.Data;
using Volo.Abp.MongoDB;

namespace LaundrySaaS.Accounting.MongoDB;

[ConnectionStringName(AccountingDbProperties.ConnectionStringName)]
public interface IAccountingMongoDbContext : IAbpMongoDbContext
{
    /* Define mongo collections here. Example:
     * IMongoCollection<Question> Questions { get; }
     */
}
