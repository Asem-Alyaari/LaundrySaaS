using Microsoft.EntityFrameworkCore;
using Volo.Abp.EntityFrameworkCore;

namespace LaundrySaaS.Accounting.EntityFrameworkCore;

public class AccountingHttpApiHostMigrationsDbContext : AbpDbContext<AccountingHttpApiHostMigrationsDbContext>
{
    public AccountingHttpApiHostMigrationsDbContext(DbContextOptions<AccountingHttpApiHostMigrationsDbContext> options)
        : base(options)
    {

    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.ConfigureAccounting();
    }
}
