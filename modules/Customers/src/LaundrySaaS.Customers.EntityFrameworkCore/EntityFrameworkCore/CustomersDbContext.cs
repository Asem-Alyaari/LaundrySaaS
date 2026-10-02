using LaundrySaaS.Customers.Customers;
using Microsoft.EntityFrameworkCore;
using Volo.Abp.Data;
using Volo.Abp.EntityFrameworkCore;

namespace LaundrySaaS.Customers.EntityFrameworkCore;

[ConnectionStringName(CustomersDbProperties.ConnectionStringName)]
public class CustomersDbContext : AbpDbContext<CustomersDbContext>, ICustomersDbContext
{
    public DbSet<Customer> Customers { get; set; } = null!;
    public DbSet<CustomerAddress> CustomerAddresses { get; set; } = null!;

    public CustomersDbContext(DbContextOptions<CustomersDbContext> options)
        : base(options)
    {

    }

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);

        builder.ConfigureCustomers();
    }
}
