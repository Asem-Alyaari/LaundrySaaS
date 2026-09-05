using System;
using Volo.Abp.Domain.Repositories;

namespace LaundrySaaS.Laundries.Laundries;

public interface ILaundryRepository : IRepository<Laundry, Guid>
{
}
