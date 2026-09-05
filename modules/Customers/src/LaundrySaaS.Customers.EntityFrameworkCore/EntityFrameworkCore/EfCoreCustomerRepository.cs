using System;
using LaundrySaaS.Customers.Customers;
using Volo.Abp.Domain.Repositories.EntityFrameworkCore;
using Volo.Abp.EntityFrameworkCore;

namespace LaundrySaaS.Customers.EntityFrameworkCore;

public class EfCoreCustomerRepository :
    EfCoreRepository<CustomersDbContext, Customer, Guid>,
    ICustomerRepository
{
    public EfCoreCustomerRepository(IDbContextProvider<CustomersDbContext> dbContextProvider)
        : base(dbContextProvider)
    {
    }
}
