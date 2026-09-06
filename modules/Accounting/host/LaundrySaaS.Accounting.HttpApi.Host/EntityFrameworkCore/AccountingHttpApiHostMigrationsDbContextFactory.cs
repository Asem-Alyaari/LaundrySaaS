using System.IO;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using Microsoft.Extensions.Configuration;

namespace LaundrySaaS.Accounting.EntityFrameworkCore;

public class AccountingHttpApiHostMigrationsDbContextFactory : IDesignTimeDbContextFactory<AccountingHttpApiHostMigrationsDbContext>
{
    public AccountingHttpApiHostMigrationsDbContext CreateDbContext(string[] args)
    {
        var configuration = BuildConfiguration();

        var builder = new DbContextOptionsBuilder<AccountingHttpApiHostMigrationsDbContext>()
            .UseSqlServer(configuration.GetConnectionString("Accounting"));

        return new AccountingHttpApiHostMigrationsDbContext(builder.Options);
    }

    private static IConfigurationRoot BuildConfiguration()
    {
        var builder = new ConfigurationBuilder()
            .SetBasePath(Directory.GetCurrentDirectory())
            .AddJsonFile("appsettings.json", optional: false);

        return builder.Build();
    }
}
