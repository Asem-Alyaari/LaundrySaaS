using Volo.Abp.Data;
using Volo.Abp.MongoDB;

namespace LaundrySaaS.MongoDB;

[ConnectionStringName(LaundrySaaSDbProperties.ConnectionStringName)]
public class LaundrySaaSMongoDbContext : AbpMongoDbContext, ILaundrySaaSMongoDbContext
{
    /* Add mongo collections here. Example:
     * public IMongoCollection<Question> Questions => Collection<Question>();
     */

    protected override void CreateModel(IMongoModelBuilder modelBuilder)
    {
        base.CreateModel(modelBuilder);

        modelBuilder.ConfigureLaundrySaaS();
    }
}
