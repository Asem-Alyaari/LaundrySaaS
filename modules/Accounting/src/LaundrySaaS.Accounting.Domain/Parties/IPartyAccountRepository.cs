using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using Volo.Abp.Domain.Repositories;

namespace LaundrySaaS.Accounting.Parties;

public interface IPartyAccountRepository : IRepository<PartyAccount, Guid>
{
    Task<PartyAccount?> FindByPartyAsync(PartyType type, Guid entityId, CancellationToken cancellationToken = default);

    Task<List<PartyAccount>> GetListByPartyTypeAsync(PartyType type, CancellationToken cancellationToken = default);
}
