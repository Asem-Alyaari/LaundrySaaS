using System;
using Volo.Abp.Domain.Repositories;

namespace LaundrySaaS.Customers.Customers;

public interface ICustomerRepository : IRepository<Customer, Guid>
{
}
