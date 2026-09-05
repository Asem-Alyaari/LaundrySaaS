using System;
using LaundrySaaS.Laundries.Laundries;
using Volo.Abp.Domain.Repositories.EntityFrameworkCore;
using Volo.Abp.EntityFrameworkCore;

namespace LaundrySaaS.Laundries.EntityFrameworkCore;

public class EfCoreLaundryRepository :
    EfCoreRepository<LaundriesDbContext, Laundry, Guid>,
    ILaundryRepository
{
    public EfCoreLaundryRepository(IDbContextProvider<LaundriesDbContext> dbContextProvider)
        : base(dbContextProvider)
    {
    }
}
