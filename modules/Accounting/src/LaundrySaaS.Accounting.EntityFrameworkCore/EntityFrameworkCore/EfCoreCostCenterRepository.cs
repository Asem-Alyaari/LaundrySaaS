using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using LaundrySaaS.Accounting.CostCenters;
using Microsoft.EntityFrameworkCore;
using Volo.Abp.Domain.Repositories.EntityFrameworkCore;
using Volo.Abp.EntityFrameworkCore;

namespace LaundrySaaS.Accounting.EntityFrameworkCore;

public class EfCoreCostCenterRepository : EfCoreRepository<IAccountingDbContext, CostCenter, Guid>, ICostCenterRepository
{
    public EfCoreCostCenterRepository(IDbContextProvider<IAccountingDbContext> dbContextProvider)
        : base(dbContextProvider)
    {

    }

    public async Task<CostCenter?> FindByCodeAsync(string code, CancellationToken cancellationToken = default)
    {
        var dbSet = await GetDbSetAsync();
        return await dbSet.FirstOrDefaultAsync(c => c.Code == code, cancellationToken);
    }

    public async Task<List<CostCenter>> GetByLaundryIdAsync(Guid laundryId, CancellationToken cancellationToken = default)
    {
        var dbSet = await GetDbSetAsync();
        return await dbSet.Where(c => c.LaundryId == laundryId).OrderBy(c => c.Code).ToListAsync(cancellationToken);
    }
}
