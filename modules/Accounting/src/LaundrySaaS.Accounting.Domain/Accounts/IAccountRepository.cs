using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using Volo.Abp.Domain.Repositories;

namespace LaundrySaaS.Accounting.Accounts;

public interface IAccountRepository : IRepository<Account, Guid>
{
    Task<Account?> FindByCodeAsync(string code, CancellationToken cancellationToken = default);

    Task<List<Account>> GetChildrenAsync(Guid parentId, CancellationToken cancellationToken = default);

    Task<List<Account>> GetLeafAccountsAsync(CancellationToken cancellationToken = default);

    Task<bool> HasChildrenAsync(Guid accountId, CancellationToken cancellationToken = default);

    Task<bool> HasTransactionsAsync(Guid accountId, CancellationToken cancellationToken = default);
}
