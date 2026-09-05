using Volo.Abp.Data;
using Volo.Abp.MongoDB;

namespace LaundrySaaS.Laundries.MongoDB;

[ConnectionStringName(LaundriesDbProperties.ConnectionStringName)]
public class LaundriesMongoDbContext : AbpMongoDbContext, ILaundriesMongoDbContext
{
    /* Add mongo collections here. Example:
     * public IMongoCollection<Question> Questions => Collection<Question>();
     */

    protected override void CreateModel(IMongoModelBuilder modelBuilder)
    {
        base.CreateModel(modelBuilder);

        modelBuilder.ConfigureLaundries();
    }
}
