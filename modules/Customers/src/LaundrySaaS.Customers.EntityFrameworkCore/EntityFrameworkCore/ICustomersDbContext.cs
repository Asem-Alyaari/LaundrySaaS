using LaundrySaaS.Customers.Customers;
using Microsoft.EntityFrameworkCore;
using Volo.Abp.Data;
using Volo.Abp.EntityFrameworkCore;

namespace LaundrySaaS.Customers.EntityFrameworkCore;

[ConnectionStringName(CustomersDbProperties.ConnectionStringName)]
public interface ICustomersDbContext : IEfCoreDbContext
{
    DbSet<Customer> Customers { get; }
    DbSet<CustomerAddress> CustomerAddresses { get; }
}
