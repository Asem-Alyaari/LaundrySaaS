using System;
using LaundrySaaS.Laundries.Categories;
using Volo.Abp.Domain.Repositories.EntityFrameworkCore;
using Volo.Abp.EntityFrameworkCore;

namespace LaundrySaaS.Laundries.EntityFrameworkCore;

public class EfCoreServiceCategoryRepository :
    EfCoreRepository<LaundriesDbContext, ServiceCategory, Guid>,
    IServiceCategoryRepository
{
    public EfCoreServiceCategoryRepository(IDbContextProvider<LaundriesDbContext> dbContextProvider)
        : base(dbContextProvider)
    {
    }
}
