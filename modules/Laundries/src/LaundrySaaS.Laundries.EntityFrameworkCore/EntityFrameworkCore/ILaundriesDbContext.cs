using Microsoft.EntityFrameworkCore;
using LaundrySaaS.Laundries.Categories;
using LaundrySaaS.Laundries.Items;
using LaundrySaaS.Laundries.Laundries;
using Volo.Abp.Data;
using Volo.Abp.EntityFrameworkCore;

namespace LaundrySaaS.Laundries.EntityFrameworkCore;

[ConnectionStringName(LaundriesDbProperties.ConnectionStringName)]
public interface ILaundriesDbContext : IEfCoreDbContext
{
    DbSet<Laundry> Laundries { get; }
    DbSet<ServiceCategory> ServiceCategories { get; }
    DbSet<ServiceItem> ServiceItems { get; }
}
