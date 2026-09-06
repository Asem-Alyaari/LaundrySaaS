using System;
using System.Threading;
using System.Threading.Tasks;
using LaundrySaaS.Accounting.FiscalYears;
using Microsoft.EntityFrameworkCore;
using Volo.Abp.Domain.Repositories.EntityFrameworkCore;
using Volo.Abp.EntityFrameworkCore;

namespace LaundrySaaS.Accounting.EntityFrameworkCore;

public class EfCoreFiscalYearRepository : EfCoreRepository<IAccountingDbContext, FiscalYear, Guid>, IFiscalYearRepository
{
    public EfCoreFiscalYearRepository(IDbContextProvider<IAccountingDbContext> dbContextProvider)
        : base(dbContextProvider)
    {

    }

    public async Task<FiscalYear?> FindByDateAsync(DateTime date, CancellationToken cancellationToken = default)
    {
        var dbSet = await GetDbSetAsync();
        return await dbSet
            .Include(y => y.Periods)
            .FirstOrDefaultAsync(y => date >= y.StartDate && date <= y.EndDate, cancellationToken);
    }

    public async Task<FiscalYear?> GetWithPeriodsAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var dbSet = await GetDbSetAsync();
        return await dbSet
            .Include(y => y.Periods)
            .FirstOrDefaultAsync(y => y.Id == id, cancellationToken);
    }
}
