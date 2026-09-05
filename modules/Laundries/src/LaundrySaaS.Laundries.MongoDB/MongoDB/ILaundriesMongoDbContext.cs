using Volo.Abp.Data;
using Volo.Abp.MongoDB;

namespace LaundrySaaS.Laundries.MongoDB;

[ConnectionStringName(LaundriesDbProperties.ConnectionStringName)]
public interface ILaundriesMongoDbContext : IAbpMongoDbContext
{
    /* Define mongo collections here. Example:
     * IMongoCollection<Question> Questions { get; }
     */
}
