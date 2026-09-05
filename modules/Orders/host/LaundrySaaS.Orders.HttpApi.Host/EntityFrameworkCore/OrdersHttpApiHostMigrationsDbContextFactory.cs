using System.IO;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using Microsoft.Extensions.Configuration;

namespace LaundrySaaS.Orders.EntityFrameworkCore;

public class OrdersHttpApiHostMigrationsDbContextFactory : IDesignTimeDbContextFactory<OrdersHttpApiHostMigrationsDbContext>
{
    public OrdersHttpApiHostMigrationsDbContext CreateDbContext(string[] args)
    {
        var configuration = BuildConfiguration();

        var builder = new DbContextOptionsBuilder<OrdersHttpApiHostMigrationsDbContext>()
            .UseSqlServer(configuration.GetConnectionString("Orders"));

        return new OrdersHttpApiHostMigrationsDbContext(builder.Options);
    }

    private static IConfigurationRoot BuildConfiguration()
    {
        var builder = new ConfigurationBuilder()
            .SetBasePath(Directory.GetCurrentDirectory())
            .AddJsonFile("appsettings.json", optional: false);

        return builder.Build();
    }
}
