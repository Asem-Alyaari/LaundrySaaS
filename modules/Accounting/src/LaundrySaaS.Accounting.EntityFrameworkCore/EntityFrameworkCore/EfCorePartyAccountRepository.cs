using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using LaundrySaaS.Accounting.Parties;
using Microsoft.EntityFrameworkCore;
using Volo.Abp.Domain.Repositories.EntityFrameworkCore;
using Volo.Abp.EntityFrameworkCore;

namespace LaundrySaaS.Accounting.EntityFrameworkCore;

public class EfCorePartyAccountRepository : EfCoreRepository<IAccountingDbContext, PartyAccount, Guid>, IPartyAccountRepository
{
    public EfCorePartyAccountRepository(IDbContextProvider<IAccountingDbContext> dbContextProvider)
        : base(dbContextProvider)
    {

    }

    public async Task<PartyAccount?> FindByPartyAsync(PartyType type, Guid entityId, CancellationToken cancellationToken = default)
    {
        var dbSet = await GetDbSetAsync();
        return await dbSet.FirstOrDefaultAsync(p => p.PartyType == type && p.EntityId == entityId, cancellationToken);
    }

    public async Task<List<PartyAccount>> GetListByPartyTypeAsync(PartyType type, CancellationToken cancellationToken = default)
    {
        var dbSet = await GetDbSetAsync();
        return await dbSet.Where(p => p.PartyType == type).ToListAsync(cancellationToken);
    }
}
