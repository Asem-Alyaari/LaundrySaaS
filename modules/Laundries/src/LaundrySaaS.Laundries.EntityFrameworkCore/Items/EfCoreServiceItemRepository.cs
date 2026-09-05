using System;
using LaundrySaaS.Laundries.Items;
using Volo.Abp.Domain.Repositories.EntityFrameworkCore;
using Volo.Abp.EntityFrameworkCore;

namespace LaundrySaaS.Laundries.EntityFrameworkCore;

public class EfCoreServiceItemRepository :
    EfCoreRepository<LaundriesDbContext, ServiceItem, Guid>,
    IServiceItemRepository
{
    public EfCoreServiceItemRepository(IDbContextProvider<LaundriesDbContext> dbContextProvider)
        : base(dbContextProvider)
    {
    }
}
