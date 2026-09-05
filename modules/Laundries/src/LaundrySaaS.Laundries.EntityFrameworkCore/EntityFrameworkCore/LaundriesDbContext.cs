using Microsoft.EntityFrameworkCore;
using LaundrySaaS.Laundries.Categories;
using LaundrySaaS.Laundries.Items;
using LaundrySaaS.Laundries.Laundries;
using Volo.Abp.Data;
using Volo.Abp.EntityFrameworkCore;

namespace LaundrySaaS.Laundries.EntityFrameworkCore;

[ConnectionStringName(LaundriesDbProperties.ConnectionStringName)]
public class LaundriesDbContext : AbpDbContext<LaundriesDbContext>, ILaundriesDbContext
{
    public DbSet<Laundry> Laundries { get; set; } = null!;
    public DbSet<ServiceCategory> ServiceCategories { get; set; } = null!;
    public DbSet<ServiceItem> ServiceItems { get; set; } = null!;

    public LaundriesDbContext(DbContextOptions<LaundriesDbContext> options)
        : base(options)
    {

    }

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);

        builder.ConfigureLaundries();
    }
}
