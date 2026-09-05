using Volo.Abp.Data;
using Volo.Abp.MongoDB;

namespace LaundrySaaS.MongoDB;

[ConnectionStringName(LaundrySaaSDbProperties.ConnectionStringName)]
public interface ILaundrySaaSMongoDbContext : IAbpMongoDbContext
{
    /* Define mongo collections here. Example:
     * IMongoCollection<Question> Questions { get; }
     */
}
