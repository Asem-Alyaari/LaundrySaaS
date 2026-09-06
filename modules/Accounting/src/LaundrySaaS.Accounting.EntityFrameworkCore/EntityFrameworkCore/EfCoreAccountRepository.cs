using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using LaundrySaaS.Accounting.Accounts;
using Microsoft.EntityFrameworkCore;
using Volo.Abp.Domain.Repositories.EntityFrameworkCore;
using Volo.Abp.EntityFrameworkCore;

namespace LaundrySaaS.Accounting.EntityFrameworkCore;

public class EfCoreAccountRepository : EfCoreRepository<IAccountingDbContext, Account, Guid>, IAccountRepository
{
    public EfCoreAccountRepository(IDbContextProvider<IAccountingDbContext> dbContextProvider)
        : base(dbContextProvider)
    {

    }

    public async Task<Account?> FindByCodeAsync(string code, CancellationToken cancellationToken = default)
    {
        var dbSet = await GetDbSetAsync();
        return await dbSet.FirstOrDefaultAsync(a => a.Code == code, cancellationToken);
    }

    public async Task<List<Account>> GetChildrenAsync(Guid parentId, CancellationToken cancellationToken = default)
    {
        var dbSet = await GetDbSetAsync();
        return await dbSet.Where(a => a.ParentId == parentId).OrderBy(a => a.Code).ToListAsync(cancellationToken);
    }

    public async Task<List<Account>> GetLeafAccountsAsync(CancellationToken cancellationToken = default)
    {
        var dbSet = await GetDbSetAsync();
        return await dbSet.Where(a => a.AllowDirectPosting && a.IsActive).OrderBy(a => a.Code).ToListAsync(cancellationToken);
    }

    public async Task<bool> HasChildrenAsync(Guid accountId, CancellationToken cancellationToken = default)
    {
        var dbSet = await GetDbSetAsync();
        return await dbSet.AnyAsync(a => a.ParentId == accountId, cancellationToken);
    }

    public async Task<bool> HasTransactionsAsync(Guid accountId, CancellationToken cancellationToken = default)
    {
        var dbContext = await GetDbContextAsync();
        return await dbContext.JournalEntryLines.AnyAsync(l => l.AccountId == accountId, cancellationToken);
    }
}
