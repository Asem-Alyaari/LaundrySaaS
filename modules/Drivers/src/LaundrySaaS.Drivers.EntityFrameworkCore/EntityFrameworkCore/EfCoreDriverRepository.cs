using System;
using LaundrySaaS.Drivers.Drivers;
using Volo.Abp.Domain.Repositories.EntityFrameworkCore;
using Volo.Abp.EntityFrameworkCore;

namespace LaundrySaaS.Drivers.EntityFrameworkCore;

public class EfCoreDriverRepository :
    EfCoreRepository<DriversDbContext, Driver, Guid>,
    IDriverRepository
{
    public EfCoreDriverRepository(IDbContextProvider<DriversDbContext> dbContextProvider)
        : base(dbContextProvider)
    {
    }
}
