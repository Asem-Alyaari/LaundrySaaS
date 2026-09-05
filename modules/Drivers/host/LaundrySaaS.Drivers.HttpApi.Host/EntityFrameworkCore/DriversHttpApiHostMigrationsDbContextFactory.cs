using System.IO;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using Microsoft.Extensions.Configuration;

namespace LaundrySaaS.Drivers.EntityFrameworkCore;

public class DriversHttpApiHostMigrationsDbContextFactory : IDesignTimeDbContextFactory<DriversHttpApiHostMigrationsDbContext>
{
    public DriversHttpApiHostMigrationsDbContext CreateDbContext(string[] args)
    {
        var configuration = BuildConfiguration();

        var builder = new DbContextOptionsBuilder<DriversHttpApiHostMigrationsDbContext>()
            .UseSqlServer(configuration.GetConnectionString("Drivers"));

        return new DriversHttpApiHostMigrationsDbContext(builder.Options);
    }

    private static IConfigurationRoot BuildConfiguration()
    {
        var builder = new ConfigurationBuilder()
            .SetBasePath(Directory.GetCurrentDirectory())
            .AddJsonFile("appsettings.json", optional: false);

        return builder.Build();
    }
}
